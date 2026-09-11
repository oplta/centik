import AppKit

/// Menü bar ve tam ekran pencerelerin üstünde kalan, odak çalmayan özel panel.
/// Bkz. docs/03-teknik-mimari.md §2.
final class NotchPanel: NSPanel {
    init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.nonactivatingPanel, .borderless],
            backing: .buffered,
            defer: false
        )
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        // Menü çubuğunun üstünde (24+3) ama screenSaver altında:
        // screenSaver seviyesinde hover/fare olayları gelmez (teşhis edildi).
        level = .mainMenu + 3
        collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary,
            .stationary,
            .ignoresCycle
        ]
        isMovableByWindowBackground = false
    }

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}
