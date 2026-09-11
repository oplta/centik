import AppKit
import SwiftUI

/// Çentik ada durumu, animasyon zamanlaması ve hover sönümleme yöneticisi.
/// Bkz. docs/06-tasarim-dili-ve-arayuz-sistemi.md §4.
@MainActor
@Observable
final class NotchViewModel {
    var isExpanded: Bool = false
    var isHovered: Bool = false
    
    // Boyut kuralları (06 §5.1: içerik 180–250 arası dinamik)
    let expandedWidth: CGFloat = 400
    let expandedHeight: CGFloat = 250
    
    func currentWidth(hasNotch: Bool, notchWidth: CGFloat) -> CGFloat {
        if isExpanded {
            return expandedWidth
        }
        // Donanım çentiği + 2x omuz kavis payı (6px sol + 6px sağ)
        return hasNotch ? max(notchWidth, 185) + 20 : 170
    }
    
    func currentHeight(hasNotch: Bool, notchHeight: CGFloat) -> CGFloat {
        if isExpanded {
            return expandedHeight
        }
        return hasNotch ? notchHeight + 6 : 32
    }

    /// Dokunsal geri bildirim (Apple Haptic Feedback)
    func performHaptic(_ pattern: NSHapticFeedbackManager.FeedbackPattern = .alignment) {
        NSHapticFeedbackManager.defaultPerformer.perform(pattern, performanceTime: .default)
    }
    
    private var hoverTask: Task<Void, Never>?
    private var closeTask: Task<Void, Never>?
    private var dismissTask: Task<Void, Never>?

    /// Fareyle etkileşim yoksa ada 8sn sonra kendiliğinden kapanır.
    /// Dışarı-tık izni (AX) yokken tek garantili kapanma yoludur; polling değil, tek atımlık Task.
    private func scheduleAutoDismiss() {
        dismissTask?.cancel()
        dismissTask = Task {
            try? await Task.sleep(nanoseconds: 8_000_000_000)
            guard !Task.isCancelled else { return }
            if isExpanded, !isHovered {
                DebugLog.log("auto-dismiss")
                collapse()
            }
        }
    }
    
    /// Fare çentik bölgesine girdiğinde / çıktığında tetiklenir
    func onHoverChanged(_ hovering: Bool) {
        DebugLog.log("hover=\(hovering) expanded=\(isExpanded)")
        isHovered = hovering
        
        if hovering {
            closeTask?.cancel()
            closeTask = nil
            
            guard !isExpanded else { return }
            
            // 0.18 saniye istem dışı açılmayı önleme sönümlemesi (§4.2)
            hoverTask = Task {
                try? await Task.sleep(nanoseconds: 180_000_000)
                guard !Task.isCancelled else { return }
                expand()
            }
        } else {
            hoverTask?.cancel()
            hoverTask = nil
            
            guard isExpanded else { return }
            
            // 0.35 saniye kapanma gecikmesi (§4.2)
            closeTask = Task {
                try? await Task.sleep(nanoseconds: 350_000_000)
                guard !Task.isCancelled else { return }
                collapse()
            }
        }
    }
    
    /// Adayı akıcı yay animasyonuyla açar
    func expand() {
        DebugLog.log("expand")
        hoverTask?.cancel()
        closeTask?.cancel()
        performHaptic(.alignment)
        withAnimation(.spring(response: 0.34, dampingFraction: 0.76)) {
            isExpanded = true
        }
        scheduleAutoDismiss()
    }

    /// Adayı kapatır
    func collapse() {
        DebugLog.log("collapse")
        hoverTask?.cancel()
        closeTask?.cancel()
        dismissTask?.cancel()
        performHaptic(.levelChange)
        withAnimation(.spring(response: 0.26, dampingFraction: 0.82)) {
            isExpanded = false
        }
    }
    
    /// Kısayol ile (⌥Space) aç/kapa
    func toggle() {
        if isExpanded {
            collapse()
        } else {
            expand()
        }
    }

    /// Uygulamayı tamamen kapatır (başlıktaki güç düğmesi).
    func quit() {
        performHaptic(.levelChange)
        NSApplication.shared.terminate(nil)
    }
}
