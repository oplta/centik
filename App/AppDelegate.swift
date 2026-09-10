import AppKit
import ApplicationServices
import SwiftUI

/// Şeffaf alanlarda tıklamaların arkadaki pencerelere/masaüstüne geçmesini sağlayan özel hosting view.
/// acceptsFirstMouse: Odak dışı panelde ilk tıklamada anında aksiyon alınmasını sağlar.
final class PassthroughHostingView<Content: View>: NSHostingView<Content> {
    var activeBoundsProvider: (() -> NSRect)?

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        true
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        guard let targetRect = activeBoundsProvider?() else {
            return super.hitTest(point)
        }
        if targetRect.contains(point) {
            return super.hitTest(point)
        }
        return nil
    }
}

/// Menü çubuğu durumu ve uygulama yaşam döngüsü.
/// v1: NotchPanel penceresini ve ada yaşam döngüsünü yönetir.
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var notchPanel: NotchPanel?
    private let screenManager = ScreenManager()
    private let viewModel = NotchViewModel()
    private let shelf = FileShelfManager()
    private let nowPlaying = NowPlayingManager()
    private let themes = ThemeManager()
    private let hotkeys = HotkeyManager()
    private let updater = UpdateManager()
    private let dragMonitor = DragMonitor()
    private var outsideClickMonitor: Any?

    private let panelWidth: CGFloat = 440
    private let panelHeight: CGFloat = 260
    private let retinaBleedOffset: CGFloat = 1.0 // Retina çerçeve içine 1px gömülme payı (sıfır saç teli boşluk)

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupNotchPanel()
        setupEventMonitors()
        hotkeys.register(
            toggle: { [weak self] in Task { @MainActor in self?.viewModel.toggle() } },
            clipboard: { [weak self] in Task { @MainActor in self?.openClipboard() } }
        )
        updater.start()
        setupDragMonitor()
        ensureDragMonitoring()
        NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.ensureDragMonitoring() }
        }
    }

    /// ⌥V: pano görünümü v0.4'e kadar paneli açar.
    private func openClipboard() {
        viewModel.expand()
    }

    // MARK: - Sürükleme izleme (Erişilebilirlik izni gerekir)

    private func setupDragMonitor() {
        dragMonitor.regionProvider = { [weak self] in
            self?.notchRegion() ?? .zero
        }
        dragMonitor.onEnterRegion = { [weak self] in
            self?.viewModel.expand()
        }
        dragMonitor.onExitRegion = { [weak self] in
            self?.viewModel.onHoverChanged(false)
        }
    }

    /// İzin yoksa sistem penceresini bir kez gösterir; ret denenirse
    /// uygulama her öne çıktığında sessizce yeniden dener.
    private func ensureDragMonitoring() {
        // Not: kAXTrustedCheckOptionPrompt extern global'i Swift 6'da paylaşılan
        // durum sayılır; değeri sabit string olarak verilir (resmi anahtar adı).
        let options = ["AXTrustedCheckOptionPrompt": true] as CFDictionary
        guard AXIsProcessTrustedWithOptions(options) else { return }
        dragMonitor.start()
    }

    /// Sürükleme bölgesi: ekran üst-orta (panel alanıyla aynı).
    private func notchRegion() -> CGRect {
        guard let screen = NSScreen.main else { return .zero }
        let width: CGFloat = 440
        let height: CGFloat = 260
        return CGRect(
            x: screen.frame.midX - width / 2,
            y: screen.frame.maxY - height,
            width: width,
            height: height
        )
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    private func setupNotchPanel() {
        guard let screen = NSScreen.notchScreen else { return }
        screenManager.update(screen: screen)

        // Panel tam olarak ekranın üst kenarına yaslanır (y = maxY - panelHeight + bleed)
        let x = screen.frame.midX - panelWidth / 2
        let y = screen.frame.maxY - panelHeight + retinaBleedOffset

        let contentRect = NSRect(x: x, y: y, width: panelWidth, height: panelHeight)
        let panel = NotchPanel(contentRect: contentRect)

        let rootView = NotchContainerView(
            viewModel: viewModel,
            screenManager: screenManager,
            shelf: shelf,
            nowPlaying: nowPlaying,
            themes: themes
        )
        let hostingView = PassthroughHostingView(rootView: rootView)
        hostingView.frame = NSRect(origin: .zero, size: contentRect.size)
        hostingView.autoresizingMask = [.width, .height]

        // Yalnızca aktif çentik sınırlarında fare olaylarını kabul et, boş alanları arkaya geçir
        hostingView.activeBoundsProvider = { [weak self, weak panel] in
            guard let self = self, let panel = panel else { return .zero }
            let width = self.viewModel.currentWidth(
                hasNotch: self.screenManager.hasNotch,
                notchWidth: self.screenManager.notchWidth
            )
            let height = self.viewModel.currentHeight(
                hasNotch: self.screenManager.hasNotch,
                notchHeight: self.screenManager.notchHeight
            )
            let pSize = panel.frame.size
            let originX = (pSize.width - width) / 2
            let originY = pSize.height - height
            return NSRect(x: originX, y: originY, width: width, height: height)
        }

        panel.contentView = hostingView
        panel.orderFrontRegardless()
        self.notchPanel = panel

        // Ekran parametresi değiştiğinde paneli tekrar konumlandır
        NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.repositionPanel()
            }
        }
    }

    private func repositionPanel() {
        guard let panel = notchPanel, let screen = NSScreen.notchScreen else { return }
        screenManager.update(screen: screen)
        let x = screen.frame.midX - panelWidth / 2
        let y = screen.frame.maxY - panelHeight + retinaBleedOffset
        panel.setFrame(NSRect(x: x, y: y, width: panelWidth, height: panelHeight), display: true)
    }

    private func setupEventMonitors() {
        // Açık durumdayken panel dışına tıklandığında adayı kapat
        outsideClickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            Task { @MainActor in
                guard let self = self, self.viewModel.isExpanded else { return }
                self.viewModel.collapse()
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        hotkeys.unregister()
        if let monitor = outsideClickMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}
