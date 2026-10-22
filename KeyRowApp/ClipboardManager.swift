import Combine
import UIKit

/// Manages the clipboard history. Watches the system pasteboard while the
/// app is active and stores the last N unique text items in shared storage
/// so the keyboard extension can read them.
final class ClipboardManager: ObservableObject {
    static let maxItems = 20

    @Published private(set) var items: [ClipboardItem] = [] {
        didSet { SharedStorage.saveClipboardItems(items) }
    }

    private var lastKnownChangeCount: Int = -1
    private var timer: Timer?

    init() {
        items = SharedStorage.loadClipboardItems()
        startPolling()
    }

    deinit {
        timer?.invalidate()
    }

    func startPolling() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkPasteboard()
        }
        checkPasteboard()
    }

    func checkPasteboard() {
        let board = UIPasteboard.general
        guard board.changeCount != lastKnownChangeCount else { return }
        lastKnownChangeCount = board.changeCount

        guard let text = board.string, !text.isEmpty else { return }
        add(text)
    }

    func add(_ text: String) {
        // De-duplicate: move existing item to the top instead of adding a copy.
        if let index = items.firstIndex(where: { $0.text == text }) {
            let item = items.remove(at: index)
            var updated = item
            updated.timestamp = Date()
            items.insert(updated, at: 0)
        } else {
            items.insert(ClipboardItem(text: text, timestamp: Date()), at: 0)
            if items.count > Self.maxItems {
                items.removeLast(items.count - Self.maxItems)
            }
        }
    }

    func remove(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }

    func copyToPasteboard(_ text: String) {
        UIPasteboard.general.string = text
    }

    func clearAll() {
        items.removeAll()
    }
}

struct ClipboardItem: Codable, Identifiable, Equatable {
    var id: String {
        text
    }

    let text: String
    var timestamp: Date
}
