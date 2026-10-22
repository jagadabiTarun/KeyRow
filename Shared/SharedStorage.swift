import Foundation

/// Shared between the host app and the keyboard extension.
/// Persists clipboard history and settings in a shared App Group container.
enum SharedStorage {
    static let appGroupId = "group.com.keyrow.shared"

    private static let clipboardKey = "clipboardItems"
    private static let settingsKey = "settings"

    // MARK: - App Group UserDefaults

    static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupId)
    }

    // MARK: - Clipboard history

    struct ClipboardItem: Codable, Identifiable, Equatable {
        var id: String {
            text
        }

        let text: String
        var timestamp: Date
    }

    static func loadClipboardItems() -> [ClipboardItem] {
        guard let defaults = sharedDefaults,
              let data = defaults.data(forKey: clipboardKey),
              let items = try? JSONDecoder().decode([ClipboardItem].self, from: data)
        else {
            return []
        }
        return items
    }

    static func saveClipboardItems(_ items: [ClipboardItem]) {
        guard let defaults = sharedDefaults,
              let data = try? JSONEncoder().encode(items) else { return }
        defaults.set(data, forKey: clipboardKey)
    }

    static func clearAll() {
        sharedDefaults?.removeObject(forKey: clipboardKey)
        NotificationCenter.default.post(name: .init("keyRowClipboardChanged"), object: nil)
    }

    // MARK: - Settings

    struct Settings: Codable {
        var numberRowEnabled = true
        var hapticsEnabled = true
        var soundEnabled = false
        var autoClipboardEnabled = true
    }

    static func loadSettings() -> Settings {
        guard let defaults = sharedDefaults,
              let data = defaults.data(forKey: settingsKey),
              let settings = try? JSONDecoder().decode(Settings.self, from: data)
        else {
            return Settings()
        }
        return settings
    }

    static func saveSettings(_ settings: Settings) {
        guard let defaults = sharedDefaults,
              let data = try? JSONEncoder().encode(settings) else { return }
        defaults.set(data, forKey: settingsKey)
    }
}
