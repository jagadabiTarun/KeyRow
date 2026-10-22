# KeyRow
A lightweight iOS keyboard with a permanent number row and text clipboard manager.

## Project structure

```
KeyRow/
├── KeyRowApp/
│   ├── ContentView.swift        # Main app screen (clipboard history list)
│   ├── ClipboardManager.swift   # Watches the pasteboard, stores history
│   └── SettingsView.swift       # Keyboard & clipboard settings
├── KeyboardExtension/
│   ├── KeyboardViewController.swift  # UIInputViewController hosting the keyboard
│   ├── KeyboardView.swift            # Root keyboard layout (ABC / 123 / symbols)
│   ├── NumberRowView.swift           # Permanent number row + full numeric pad
│   ├── SymbolView.swift              # "#+=" symbol page
│   └── ClipboardView.swift           # In-keyboard clipboard picker
└── Shared/
    └── SharedStorage.swift      # App Group container for shared clipboard & settings
```

## Building

1. Open the project in Xcode and create targets for the app (`KeyRowApp`) and a Keyboard Extension (`KeyboardExtension`), plus an App Group such as `group.com.keyrow.shared` for both targets.
2. Update the `appGroupId` in `Shared/SharedStorage.swift` if you use a different App Group identifier.
3. Build and run on an iOS device or simulator.

## Using the keyboard

1. Settings → General → Keyboard → Keyboards → Add New Keyboard… → KeyRow
2. Tap KeyRow and enable **Allow Full Access** (required for the clipboard features).
3. The number row is always visible above the letters; use `123` for the numeric pad, `#+=` for symbols, and `⌘` for the clipboard picker.
