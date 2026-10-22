import SwiftUI

/// Clipboard history picker shown inside the keyboard. Tap an entry to
/// insert it into the focused text field.
struct ClipboardView: View {
    @Binding var items: [ClipboardItem]
    let onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Clipboard")
                    .font(.headline)
                Spacer()
                Text("\(items.count) items")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if items.isEmpty {
                Text("No copied text yet.\nCopy something in another app, then come back.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 24)
            } else {
                List {
                    ForEach(items) { item in
                        Button {
                            onSelect(item.text)
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.text)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                    .lineLimit(2)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text(item.timestamp, style: .relative)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        items.remove(atOffsets: indexSet)
                        SharedStorage.saveClipboardItems(items)
                    }
                }
                .listStyle(.plain)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

struct ClipboardView_Previews: PreviewProvider {
    static var previews: some View {
        ClipboardView(
            items: .constant([
                ClipboardItem(text: "hello@example.com", timestamp: Date()),
                ClipboardItem(text: "Some copied snippet", timestamp: Date())
            ]),
            onSelect: { _ in }
        )
        .padding()
    }
}
