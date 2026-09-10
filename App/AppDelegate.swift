import AppKit
import SwiftUI

/// Menü çubuğu durumu ve uygulama yaşam döngüsü.
/// v1: NotchPanel penceresini ve ada yaşam döngüsünü yönetir.
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var notchPanel: NotchPanel?
    private let screenManager = ScreenManager()
    private let viewModel = NotchViewModel()
    private var eventMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupNotchPanel()
        setupEventMonitor()
    }

    private func setupNotchPanel() {
        guard let screen = NSScreen.main else { return }
        screenManager.update(screen: screen)

        let initialWidth: CGFloat = 420
        let initialHeight: CGFloat = 240
        let x = screen.frame.midX - initialWidth / 2
        let y = screen.frame.maxY - initialHeight

        let contentRect = NSRect(x: x, y: y, width: initialWidth, height: initialHeight)
        let panel = NotchPanel(contentRect: contentRect)

        let rootView = NotchContainerView(viewModel: viewModel, screenManager: screenManager)
        let hostingView = NSHostingView(rootView: rootView)
        hostingView.frame = NSRect(origin: .zero, size: contentRect.size)
        hostingView.autoresizingMask = [.width, .height]

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
        guard let panel = notchPanel, let screen = NSScreen.main else { return }
        screenManager.update(screen: screen)
        let x = screen.frame.midX - panel.frame.width / 2
        let y = screen.frame.maxY - panel.frame.height
        panel.setFrameOrigin(NSPoint(x: x, y: y))
    }

    private func setupEventMonitor() {
        // Esc tuşuna basıldığında adayı kapat
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 53 { // 53 = Esc
                Task { @MainActor in
                    self?.viewModel.collapse()
                }
            }
            return event
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}
