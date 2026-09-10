import AppKit

extension NSScreen {
    /// Fiziksel donanım çentiği olan ekranı bulur; çentikli ekran yoksa ana ekranı döner.
    static var notchScreen: NSScreen? {
        if let notched = NSScreen.screens.first(where: {
            guard let tl = $0.auxiliaryTopLeftArea, let tr = $0.auxiliaryTopRightArea else { return false }
            return ($0.frame.width - (tl.width + tr.width)) > 10
        }) {
            return notched
        }
        return NSScreen.main ?? NSScreen.screens.first
    }
}

/// Ekran çentik tespiti ve hap (floating pill) fallback yöneticisi.
/// Kural: auxiliary alanlar toplamı ekran genişliğinden küçükse çentik vardır.
/// `safeAreaInsets` iOS API'sidir, macOS'ta kullanılmaz.
@MainActor
@Observable
final class ScreenManager {
    private(set) var hasNotch = false
    private(set) var notchWidth: CGFloat = 0
    private(set) var notchHeight: CGFloat = 34

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

    func update(screen: NSScreen? = NSScreen.notchScreen) {
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
