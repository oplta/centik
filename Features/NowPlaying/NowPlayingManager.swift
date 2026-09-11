import AppKit
import Foundation

/// Sistem genelinde çalan medyayı gösterir (Music, Spotify, tarayıcı, diğer uygulamalar).
///
/// Yöntem: MediaRemote private framework'ü CFBundle ile yüklenir (Boring Notch
/// ile aynı teknik), bağlantı anında bağımlılık yoktur. Olay akışı tamamen
/// event-driven'dır (Darwin notify → bilgi çek); polling YOK.
///
/// Not: private API App Store'a giremez. Çentik DMG/Homebrew dağıtıldığı için
/// sorun değildir; olası bir App Store lite sürümünde bu dosya derlemeden çıkarılır.
/// Sembol bulunamazsa yönetici sessizce boş duruma düşer (crash yok).
@MainActor
@Observable
final class NowPlayingManager {
    private(set) var track: String?
    private(set) var artist: String?
    private(set) var artwork: NSImage?
    private(set) var isPlaying = false

    var headline: String { track ?? "Now Playing" }
    var subline: String {
        if let artist, !artist.isEmpty { return artist }
        if track != nil { return "Çalıyor" }
        return "Müzik çalmıyor"
    }

    // Gözlem dışı + nonisolated(unsafe) gerekçesi: UI state'i değildir;
    // yalnızca @MainActor init içinde, obje kaçmadan yazılır.
    // Bundle Boring Notch ile aynı yöntemle tutulur (CFBundleCreate).
    @ObservationIgnored nonisolated(unsafe) private var mediaBundle: CFBundle?
    @ObservationIgnored nonisolated(unsafe) private var legacyObservers: [NSObjectProtocol] = []

    private typealias MRRegisterFn = @convention(c) (DispatchQueue) -> Void
    private typealias MRGetInfoFn = @convention(c) (
        DispatchQueue,
        @escaping @convention(block) (CFDictionary?) -> Void
    ) -> Void

    init() {
        guard let bundle = CFBundleCreate(
            kCFAllocatorDefault,
            URL(fileURLWithPath: "/System/Library/PrivateFrameworks/MediaRemote.framework") as CFURL
        ) else {
            DebugLog.log("mr-bundle yok, legacy moda düşüldü")
            registerLegacyObservers()
            return
        }
        self.mediaBundle = bundle

        guard let register = loadFunction("MRMediaRemoteRegisterForNowPlayingNotifications", as: MRRegisterFn.self)
        else {
            DebugLog.log("mr-register bulunamadı, legacy moda düşüldü")
            registerLegacyObservers()
            return
        }
        register(DispatchQueue.main)
        let infoOK = observeDarwinNotification(symbol: "kMRMediaRemoteNowPlayingInfoDidChangeNotification")
        let appOK = observeDarwinNotification(symbol: "kMRMediaRemoteNowPlayingApplicationDidChangeNotification")
        DebugLog.log("mr-notify info=\(infoOK) app=\(appOK)")
        refresh()
    }

    deinit {
        let center = DistributedNotificationCenter.default()
        for observer in legacyObservers {
            center.removeObserver(observer)
        }
    }

    // MARK: - Bilgi çekme

    /// Son bilgiyi MediaRemote'dan çeker (yalnızca olay sonrası çağrılır).
    func refresh() {
        guard let getInfo = loadFunction("MRMediaRemoteGetNowPlayingInfo", as: MRGetInfoFn.self)
        else { return }
        getInfo(DispatchQueue.main) { [weak self] info in
            guard let dict = info as? [String: Any] else {
                Task { @MainActor in DebugLog.log("mr-refresh: boş sözlük") }
                return
            }
            // Sınırda Sendable değerlere indirge, sonra MainActor'a geç.
            let title = dict["kMRMediaRemoteNowPlayingInfoTitle"] as? String
            let artist = dict["kMRMediaRemoteNowPlayingInfoArtist"] as? String
            let art = dict["kMRMediaRemoteNowPlayingInfoArtworkData"] as? Data
            let rate = dict["kMRMediaRemoteNowPlayingInfoPlaybackRate"] as? Double ?? 0
            Task { @MainActor in
                DebugLog.log("mr-refresh title=\(title ?? "-") artist=\(artist ?? "-") rate=\(rate)")
                self?.apply(title: title, artist: artist, artworkData: art, rate: rate)
            }
        }
    }

    private func apply(title: String?, artist: String?, artworkData: Data?, rate: Double) {
        // Boş bilgi (duraklatılıp kuyruk temizlenince) kartı sıfırlar.
        guard title != nil || artist != nil else {
            track = nil
            self.artist = nil
            artwork = nil
            isPlaying = false
            return
        }
        track = title
        self.artist = artist
        if let artworkData, let image = NSImage(data: artworkData) {
            artwork = image
        } else {
            artwork = nil
        }
        isPlaying = rate == 1
    }

    // MARK: - Darwin notify

    @discardableResult
    private func observeDarwinNotification(symbol: String) -> Bool {
        guard let name = loadNotifyName(symbol: symbol) else { return false }
        let opaque = Unmanaged.passUnretained(self).toOpaque()
        Self.registerDarwinObserver(opaque: opaque, name: name)
        return true
    }

    /// C-callback dönüşümü @MainActor bağlamında derleyiciyi çakar;
    /// bu yüzden kayıt nonisolated statik zeminde yapılır.
    nonisolated private static func registerDarwinObserver(
        opaque: UnsafeMutableRawPointer,
        name: CFString
    ) {
        let callback: CFNotificationCallback = { _, observer, _, _, _ in
            guard let observer else { return }
            let manager = Unmanaged<NowPlayingManager>.fromOpaque(observer).takeUnretainedValue()
            Task { @MainActor in manager.refresh() }
        }
        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            opaque,
            callback,
            name,
            nil,
            .deliverImmediately
        )
    }

    /// Bildirim adı `NSString * const` verisidir: CFBundle API'si deponun
    /// adresini verir, pointer yüklenir ve tip doğrulanır. Ham probe crash verir.
    private func loadNotifyName(symbol: String) -> CFString? {
        guard let mediaBundle,
              let storage = CFBundleGetDataPointerForName(mediaBundle, symbol as CFString)
        else { return nil }
        let loaded = storage.load(as: CFString.self)
        guard CFGetTypeID(loaded) == CFStringGetTypeID() else { return nil }
        return loaded
    }

    private func loadFunction<T>(_ symbol: String, as type: T.Type) -> T? {
        guard let mediaBundle,
              let ptr = CFBundleGetFunctionPointerForName(mediaBundle, symbol as CFString)
        else { return nil }
        return unsafeBitCast(ptr, to: T.self)
    }

    // MARK: - Eski yol (MediaRemote yoksa)

    private func registerLegacyObservers() {
        let center = DistributedNotificationCenter.default()
        legacyObservers.append(
            center.addObserver(
                forName: NSNotification.Name("com.apple.Music.playerInfo"),
                object: nil,
                queue: .main
            ) { [weak self] note in
                let state = note.userInfo?["Player State"] as? String
                let name = note.userInfo?["Name"] as? String
                let artist = note.userInfo?["Artist"] as? String
                Task { @MainActor in
                    self?.track = name
                    self?.artist = artist
                    self?.isPlaying = state == "Playing"
                }
            }
        )
    }
}
