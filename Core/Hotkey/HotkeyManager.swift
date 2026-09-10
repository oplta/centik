import AppKit
import Carbon

/// Global kısayollar: ⌥Space (aç/kapa), ⌥V (pano/paneli aç).
/// Carbon RegisterEventHotKey kullanır — Erişilebilirlik/İzleme izni gerekmez.
/// Olaylar ana runloop üzerinden gelir; bkz. docs/02 §1.
@MainActor
final class HotkeyManager {
    static let toggleID: UInt32 = 1
    static let clipboardID: UInt32 = 2

    /// 'CNTK' imza (Carbon OSType, FourCharCode el ile).
    private static let signature: OSType = 0x434E_544B

    private var hotKeyRefs: [EventHotKeyRef?] = []
    private var eventHandler: EventHandlerRef?

    /// Aksiyonları köprüye verir, Carbon olayını kurar, tuşları kaydeder.
    /// Closure'lar MainActor'a Task ile zıplar (Carbon zemini nonisolated).
    func register(
        toggle: @Sendable @escaping () -> Void,
        clipboard: @Sendable @escaping () -> Void
    ) {
        HotkeyBridge.shared.setAction(id: Self.toggleID, action: toggle)
        HotkeyBridge.shared.setAction(id: Self.clipboardID, action: clipboard)

        var spec = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        InstallEventHandler(
            GetApplicationEventTarget(),
            hotkeyEventHandler,
            1,
            &spec,
            nil,
            &eventHandler
        )
        registerKey(id: Self.toggleID, modifiers: UInt32(optionKey), keyCode: UInt32(kVK_Space))
        registerKey(id: Self.clipboardID, modifiers: UInt32(optionKey), keyCode: UInt32(kVK_ANSI_V))
    }

    func unregister() {
        for ref in hotKeyRefs {
            if let ref { UnregisterEventHotKey(ref) }
        }
        hotKeyRefs.removeAll()
        if let eventHandler { RemoveEventHandler(eventHandler) }
        eventHandler = nil
    }

    private func registerKey(id: UInt32, modifiers: UInt32, keyCode: UInt32) {
        var ref: EventHotKeyRef?
        let hotID = EventHotKeyID(signature: Self.signature, id: id)
        guard RegisterEventHotKey(
            keyCode, modifiers, hotID,
            GetApplicationEventTarget(), 0, &ref
        ) == noErr, let ref else { return }
        hotKeyRefs.append(ref)
    }
}

/// Carbon olayı → kayıtlı aksiyon köprüsü.
/// Kilit değişmezi: tüm erişim tek kilit altında; closure'lar @Sendable ve
/// MainActor'a Task ile zıplar, paylaşılan değişken durum tutulmaz.
// Değişmezlik gerekçesi: yazma/okuma hep tek kilit altında; saklanan
// closure'lar @Sendable ve paylaşılan değişken durum tutulmaz.
final class HotkeyBridge: @unchecked Sendable {
    static let shared = HotkeyBridge()

    private let lock = NSLock()
    private var actions: [UInt32: @Sendable () -> Void] = [:]

    func setAction(id: UInt32, action: @Sendable @escaping () -> Void) {
        lock.lock()
        actions[id] = action
        lock.unlock()
    }

    func fire(id: UInt32) {
        lock.lock()
        let action = actions[id]
        lock.unlock()
        action?()
    }
}

/// Carbon olay proc'u (global, nonisolated — C uyumlu).
private func hotkeyEventHandler(
    _ nextHandler: EventHandlerCallRef?,
    _ event: EventRef?,
    _ userData: UnsafeMutableRawPointer?
) -> OSStatus {
    var hotKeyID = EventHotKeyID()
    guard GetEventParameter(
        event,
        UInt32(kEventParamDirectObject),
        UInt32(typeEventHotKeyID),
        nil,
        MemoryLayout<EventHotKeyID>.size,
        nil,
        &hotKeyID
    ) == noErr else {
        return OSStatus(eventNotHandledErr)
    }
    HotkeyBridge.shared.fire(id: hotKeyID.id)
    return noErr
}
