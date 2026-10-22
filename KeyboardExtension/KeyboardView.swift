import SwiftUI

// MARK: - Shared types

enum KeyboardType: Equatable {
    case alphabetic
    case numeric
    case symbols
    case clipboard
}

enum ShiftState {
    case lower, shift, locked
}

enum KeyAction: Equatable {
    case character(String)
    case backspace
    case space
    case return_
    case shift
    case toggleMode(KeyboardType)
    case dismiss
    case pasteText(String)
}

// MARK: - KeyboardView

/// Root SwiftUI view of the keyboard. Shows a permanent number row on the
/// alphabetic layout, plus mode-switch / clipboard rows at the bottom.
struct KeyboardView: View {
    @State var keyboardType: KeyboardType
    @State var shiftState: ShiftState
    let onKey: (KeyAction) -> Void

    @State private var clipboardItems: [ClipboardItem] = SharedStorage.loadClipboardItems()

    var body: some View {
        VStack(spacing: 6) {
            switch keyboardType {
            case .alphabetic:
                NumberRowView(onKey: onKey)
                alphabetRows
            case .numeric:
                NumberRowView(onKey: onKey, fullNumericLayout: true)
                numericBottomRow
            case .symbols:
                SymbolView(onKey: onKey)
            case .clipboard:
                ClipboardView(items: $clipboardItems) { text in
                    onKey(.pasteText(text))
                }
            }
            bottomBar
        }
        .padding(6)
        .background(Color(UIColor.systemGray5))
        .onReceive(NotificationCenter.default.publisher(for: .keyRowClipboardChanged)) { _ in
            clipboardItems = SharedStorage.loadClipboardItems()
        }
    }

    private var alphabetRows: some View {
        VStack(spacing: 6) {
            let rows = [["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
                        ["a", "s", "d", "f", "g", "h", "j", "k", "l"],
                        ["z", "x", "c", "v", "b", "n", "m"]]
            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                HStack(spacing: 6) {
                    if index == 2 {
                        shiftKey
                    }
                    ForEach(row, id: \.self) { key in
                        TextKey(label: shifted(label: key)) {
                            onKey(.character(shifted(label: key)))
                        }
                    }
                    if index == 2 {
                        backspaceKey
                    }
                }
            }
        }
    }

    private var numericBottomRow: some View {
        HStack(spacing: 6) {
            TextKey(label: "#+=") { onKey(.toggleMode(.symbols)) }
            TextKey(label: "0") { onKey(.character("0")) }
            TextKey(label: "space", width: 160) { onKey(.space) }
            TextKey(label: "⏎", width: 60) { onKey(.return_) }
        }
    }

    private var bottomBar: some View {
        HStack(spacing: 6) {
            TextKey(label: "🌐", width: 44) { onKey(.dismiss) }
            if keyboardType == .alphabetic {
                TextKey(label: "123") { onKey(.toggleMode(.numeric)) }
            } else {
                TextKey(label: "ABC") { onKey(.toggleMode(.alphabetic)) }
            }
            TextKey(label: "⌘", width: 44) { onKey(.toggleMode(.clipboard)) }
            TextKey(label: "space", width: 140) { onKey(.space) }
            TextKey(label: "⏎") { onKey(.return_) }
        }
    }

    private var shiftKey: some View {
        Button {
            onKey(.shift)
        } label: {
            Text(shiftState == .locked ? "⇪" : "⇧")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .keyStyle(active: shiftState != .lower)
    }

    private var backspaceKey: some View {
        Button {
            onKey(.backspace)
        } label: {
            Text("⌫").frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .keyStyle(active: false)
    }

    private func shifted(label: String) -> String {
        guard shiftState != .lower else { return label }
        return label.uppercased()
    }
}

struct TextKey: View {
    let label: String
    var width: CGFloat?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .keyStyle(active: false)
        .frame(width: width)
    }
}

// MARK: - Helpers

extension View {
    func keyStyle(active: Bool) -> some View {
        font(.system(size: 17))
            .foregroundColor(.primary)
            .background(active ? Color(UIColor.systemGray2) : Color.white)
            .cornerRadius(6)
            .frame(height: 42)
    }
}

extension Notification.Name {
    static let keyRowClipboardChanged = Notification.Name("keyRowClipboardChanged")
}
