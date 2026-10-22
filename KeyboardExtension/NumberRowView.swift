import SwiftUI

/// The permanent number row shown above the alphabetic keyboard, and the
/// full numeric layout when `fullNumericLayout` is true.
struct NumberRowView: View {
    let onKey: (KeyAction) -> Void
    var fullNumericLayout = false

    private let numberRow = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
    private let mathKeys = ["+", "-", "×", "÷", "="]
    private let punctuation = [",", ".", "?", "!", "'"]

    var body: some View {
        if fullNumericLayout {
            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    ForEach(numberRow, id: \.self) { key in
                        TextKey(label: key) { onKey(.character(key)) }
                    }
                }
                HStack(spacing: 6) {
                    ForEach(mathKeys, id: \.self) { key in
                        TextKey(label: key) { onKey(.character(key)) }
                    }
                    TextKey(label: "(", width: 42) { onKey(.character("(")) }
                    TextKey(label: ")", width: 42) { onKey(.character(")")) }
                    TextKey(label: "⌫") { onKey(.backspace) }
                }
            }
        } else {
            HStack(spacing: 6) {
                ForEach(numberRow, id: \.self) { key in
                    TextKey(label: key) { onKey(.character(key)) }
                }
            }
        }
    }
}

struct NumberRowView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 8) {
            NumberRowView(onKey: { _ in })
            NumberRowView(onKey: { _ in }, fullNumericLayout: true)
        }
        .padding()
        .background(Color(UIColor.systemGray5))
    }
}
