import SwiftUI

struct SettingsView: View {
    @AppStorage("numberRowEnabled") private var numberRowEnabled = true
    @AppStorage("hapticsEnabled") private var hapticsEnabled = true
    @AppStorage("soundEnabled") private var soundEnabled = false
    @AppStorage("autoClipboardEnabled") private var autoClipboardEnabled = true
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section("Keyboard") {
                    Toggle("Permanent number row", isOn: $numberRowEnabled)
                    Toggle("Haptic feedback", isOn: $hapticsEnabled)
                    Toggle("Key sounds", isOn: $soundEnabled)
                }
                Section("Clipboard") {
                    Toggle("Auto-capture copied text", isOn: $autoClipboardEnabled)
                }
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Enable the keyboard")
                            .font(.headline)
                        Text(
                            "1. Open the Settings app\n2. Go to General → Keyboard → Keyboards\n3. Tap Add New Keyboard…\n4. Choose KeyRow\n5. Tap KeyRow and allow Full Access"
                        )
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                Section {
                    Button("Clear clipboard history", role: .destructive) {
                        SharedStorage.clearAll()
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
