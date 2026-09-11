import AppKit
import UniformTypeIdentifiers

/// Sürükleme-bölge izleyici (Boring `DragDetector` patterni, sıfırdan yazım).
/// SwiftUI hover/drop-hedefi çentik şeridinde güvenilmez olduğu için (olaylar
/// menü çubuğuna düşer): global fare + drag-pasteboard + ekran-bölge testiyle çalışır.
/// Yalnızca fare hareket ederken/sürükleme varken uyanır; boşta maliyeti yoktur.
/// Gereksinim: Erişilebilirlik izni (AppDelegate ister).
@MainActor
final class DragMonitor {
    /// Çentik bölgesi (ekran koordinatları). Fare buraya içerikle girince açılır.
    var regionProvider: (() -> CGRect)?
    var onEnterRegion: (() -> Void)?
    var onExitRegion: (() -> Void)?
    var onHoverEnter: (() -> Void)?
    var onHoverExit: (() -> Void)?

    private var mouseDownMonitor: Any?
    private var mouseDraggedMonitor: Any?
    private var mouseUpMonitor: Any?
    private var mouseMovedMonitor: Any?

    private let dragPasteboard = NSPasteboard(name: .drag)
    private var pasteboardChangeCount = -1
    private var isDragging = false
    private var isContentDragging = false
    private var hasEnteredRegion = false

    private static let validTypes: [NSPasteboard.PasteboardType] = [
        .fileURL,
        NSPasteboard.PasteboardType(UTType.url.identifier),
        .string,
    ]

    func start() {
        stop()
        mouseDownMonitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.pasteboardChangeCount = self.dragPasteboard.changeCount
                self.isDragging = true
                self.isContentDragging = false
                self.hasEnteredRegion = false
            }
        }
        mouseDraggedMonitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDragged) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in self.handleDragged() }
        }
        mouseUpMonitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseUp) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.isDragging = false
                self.isContentDragging = false
                self.hasEnteredRegion = false
                self.pasteboardChangeCount = -1
            }
        }
        // Sürükleme yokken konuma göre hover: çentik şeridinde SwiftUI
        // tracking çalışmadığı için bölge testiyle aç/kapa.
        mouseMovedMonitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in self.handleMoved() }
        }
    }

    private func handleMoved() {
        // Sürükleme anında drag mantığı söz sahibidir.
        guard !isDragging, let regionProvider else { return }
        let inside = regionProvider().contains(NSEvent.mouseLocation)
        if inside, !hasEnteredRegion {
            hasEnteredRegion = true
            DebugLog.log("hover-enter region")
            onHoverEnter?()
        } else if !inside, hasEnteredRegion {
            hasEnteredRegion = false
            DebugLog.log("hover-exit region")
            onHoverExit?()
        }
    }

    func stop() {
        for monitor in [mouseDownMonitor, mouseDraggedMonitor, mouseUpMonitor, mouseMovedMonitor] {
            if let monitor { NSEvent.removeMonitor(monitor) }
        }
        mouseDownMonitor = nil
        mouseDraggedMonitor = nil
        mouseUpMonitor = nil
        mouseMovedMonitor = nil
        isDragging = false
        isContentDragging = false
        hasEnteredRegion = false
    }

    private func handleDragged() {
        guard isDragging, let regionProvider else { return }
        if !isContentDragging {
            guard dragPasteboard.changeCount != pasteboardChangeCount,
                  hasValidContent()
            else { return }
            isContentDragging = true
        }
        let point = NSEvent.mouseLocation
        onEnterExitIfNeeded(point: point, region: regionProvider())
    }

    private func hasValidContent() -> Bool {
        dragPasteboard.types?.contains(where: Self.validTypes.contains) ?? false
    }

    private func onEnterExitIfNeeded(point: CGPoint, region: CGRect) {
        let inside = region.contains(point)
        if inside, !hasEnteredRegion {
            hasEnteredRegion = true
            DebugLog.log("drag-enter region")
            onEnterRegion?()
        } else if !inside, hasEnteredRegion {
            hasEnteredRegion = false
            DebugLog.log("drag-exit region")
            onExitRegion?()
        }
    }
}
