import AppKit

/// Ekran çentik tespiti ve hap (floating pill) fallback yöneticisi.
/// Kural: auxiliary alanlar toplamı ekran genişliğinden küçükse çentik vardır.
/// `safeAreaInsets` iOS API'sidir, macOS'ta kullanılmaz.
@MainActor
final class ScreenManager: ObservableObject {
    @Published private(set) var hasNotch = false
    @Published private(set) var notchWidth: CGFloat = 0
    @Published private(set) var notchHeight: CGFloat = 34

    init() {
        update()
        NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.update() }
        }
    }

    func update(screen: NSScreen? = NSScreen.main) {
        guard let screen,
              let topLeft = screen.auxiliaryTopLeftArea,
              let topRight = screen.auxiliaryTopRightArea else {
            hasNotch = false
            notchWidth = 0
            notchHeight = 32
            return
        }
        let auxWidth = topLeft.width + topRight.width
        let gap = screen.frame.width - auxWidth
        hasNotch = gap > 10
        notchWidth = hasNotch ? gap : 0
        notchHeight = hasNotch ? topLeft.height : 32
    }
}
