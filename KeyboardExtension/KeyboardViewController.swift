import UIKit

/// The keyboard extension's main controller. Hosts the SwiftUI keyboard view
/// and forwards taps back into the text document proxy.
class KeyboardViewController: UIInputViewController {
    private var keyboardView: UIHostingController<KeyboardView>?
    private var isCapsLocked = false
    private var isShifted = true // start with auto-capitalization

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        view.backgroundColor = .clear
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardView?.rootView.keyboardType = currentKeyboardType()
    }

    override func textWillChange(_: UITextInput?) {
        keyboardView?.rootView.keyboardType = currentKeyboardType()
    }

    override func textDidChange(_: UITextInput?) {
        // Auto-capitalization at sentence starts
        if isCapsLocked {
            return
        }
        let context = textDocumentProxy
        let before = context.documentContextBeforeInput
        isShifted = before == nil || before?.last == "\n"
            || before?.last == "." || before?.last == "!" || before?.last == "?"
        keyboardView?.rootView.shiftState = isCapsLocked ? .locked : (isShifted ? .shift : .lower)
    }

    private func setupView() {
        let rootView = KeyboardView(
            keyboardType: currentKeyboardType(),
            shiftState: .shift,
            onKey: { [weak self] action in self?.handle(action) }
        )
        let controller = UIHostingController(rootView: rootView)
        controller.view.backgroundColor = .clear
        addChild(controller)
        view.addSubview(controller.view)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            controller.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controller.view.topAnchor.constraint(equalTo: view.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        controller.didMove(toParent: self)
        keyboardView = controller
    }

    private func currentKeyboardType() -> KeyboardType {
        textDocumentProxy.keyboardType == .numberPad ? .numeric : .alphabetic
    }

    private func handle(_ action: KeyAction) {
        let context = textDocumentProxy
        switch action {
        case let .character(char):
            context.insertText(char)
            if isShifted, !isCapsLocked {
                isShifted = false
                keyboardView?.rootView.shiftState = .lower
            }
        case .backspace:
            context.deleteBackward()
        case .space:
            context.insertText(" ")
        case .return_:
            context.insertText("\n")
        case .shift:
            if isShifted {
                isCapsLocked = true
            } else {
                isCapsLocked = false; isShifted.toggle()
            }
            keyboardView?.rootView
                .shiftState = isCapsLocked ? .locked : (isShifted ? .shift : .lower)
        case let .toggleMode(mode):
            keyboardView?.rootView.keyboardType = mode
        case .dismiss:
            dismissKeyboard()
        case let .pasteText(text):
            context.insertText(text)
        }
    }
}
