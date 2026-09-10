import Foundation

#if canImport(Sparkle)
import Sparkle
#endif

/// Otomatik güncelleme yöneticisi (Sparkle appcast).
///
/// Kurallar:
/// - Homebrew Caskroom altından çalışıyorsa Sparkle BAŞLATILMAZ
///   (`brew upgrade` yönetir; çift güncelleyici kavga çıkarır).
/// - Sürüm numarası kodda değil, git tag'indedir; paketleme scripti
///   (`scripts/package-app.sh`) tag'den Info.plist'e yazar.
/// Bkz. docs/08-guncelleme-altyapisi.md
@MainActor
final class UpdateManager: NSObject {
    #if canImport(Sparkle)
    private var controller: SPUStandardUpdaterController?
    #endif

    static var isHomebrewInstall: Bool {
        Bundle.main.bundlePath.contains("/Caskroom/")
    }

    override init() {
        super.init()
    }

    /// Arka plan periyodik kontrolü başlatır (Sparkle varsayılanı: günlük).
    func start() {
        #if canImport(Sparkle)
        guard !Self.isHomebrewInstall else { return }
        controller = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
        #endif
    }

    /// Ayarlar menüsündeki "Güncellemeleri denetle" düğmesine bağlanır.
    func checkNow() {
        #if canImport(Sparkle)
        controller?.checkForUpdates(nil)
        #endif
    }
}
