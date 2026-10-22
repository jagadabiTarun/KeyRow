import SwiftUI

/// Full symbol layout (the "#+=" page).
struct SymbolView: View {
    let onKey: (KeyAction) -> Void

    private let rows: [[String]] = [
        ["[", "]", "{", "}", "#", "%", "^", "*", "+", "="],
        ["_", "\\", "|", "~", "<", ">", "$", "€", "£", "¥"],
        ["•", "·", "…", ":", ";", "!", "?", "\"", "'", ","]
    ]

    var body: some View {
        VStack(spacing: 6) {
            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                HStack(spacing: 6) {
                    if index == 2 {
                        TextKey(label: "ABC", width: 70) { onKey(.toggleMode(.alphabetic)) }
                    }
                    ForEach(row, id: \.self) { key in
                        TextKey(label: key) { onKey(.character(key)) }
                    }
                    if index == 2 {
                        TextKey(label: "⌫") { onKey(.backspace) }
                    }
                }
            }
        }
    }
}

struct SymbolView_Previews: PreviewProvider {
    static var previews: some View {
        SymbolView(onKey: { _ in })
            .padding()
            .background(Color(UIColor.systemGray5))
    }
}
