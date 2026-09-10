import SwiftUI

/// Ada renkleri için tema protokolü.
/// Pro sürümdeki özel temalar bu arayüzü gerçekler (docs/01 §4).
/// Ölçek/hareket sabitleri appearance bağımsızdır, `CentikTheme`'de durur.
protocol IslandTheme: Sendable {
    var name: String { get }
    /// Ada ana yüzeyi (§2.1)
    var base: Color { get }
    /// Etkileşim kartları (§2.1)
    var card: Color { get }
    /// Panel ve kart çerçeveleri (§2.1, 1.5px)
    var border: Color { get }
    /// Birincil aksiyon (§3)
    var primary: Color { get }
    /// Canlı vurgu: müzik dalgası, rozet (§3)
    var accent: Color { get }
    /// Yumuşak vurgu: başlık metni, kısayol tuşları (§3)
    var accentSoft: Color { get }
    /// Birincil metin (§3)
    var textPrimary: Color { get }
    /// İkincil metin (§3)
    var textMuted: Color { get }
    /// Kart iç kenarlığı: 1px rgba(255,255,255,0.07) (§2.1)
    var cardInnerStroke: Color { get }
    /// Üst speküler yansıma: rgba(255,255,255,0.18) (§2.1)
    var specularRim: Color { get }
    /// Kart hover aydınlanması: rgba(255,255,255,0.05) (§5.3)
    var hoverWash: Color { get }
}

/// Varsayılan tema.
/// Bilinçli karar: donanım çentiği her zaman siyah olduğu için ada
/// açık/koyu görünüm fark etmez, her zaman koyu kalır ve çentikle bütünleşir.
struct ObsidianTheme: IslandTheme {
    let name = "Obsidyen"
    let base = Color(red: 7 / 255, green: 9 / 255, blue: 14 / 255)
    let card = Color(red: 17 / 255, green: 21 / 255, blue: 34 / 255)
    let border = Color(red: 30 / 255, green: 41 / 255, blue: 59 / 255)
    let primary = Color(red: 0 / 255, green: 102 / 255, blue: 255 / 255)
    let accent = Color(red: 0 / 255, green: 180 / 255, blue: 255 / 255)
    let accentSoft = Color(red: 56 / 255, green: 189 / 255, blue: 248 / 255)
    let textPrimary = Color.white
    let textMuted = Color(red: 148 / 255, green: 163 / 255, blue: 184 / 255)
    let cardInnerStroke = Color.white.opacity(0.07)
    let specularRim = Color.white.opacity(0.18)
    let hoverWash = Color.white.opacity(0.05)
}

/// Aktif temayı tutar. Pro temalar `current`'i değiştirerek devreye girer.
@MainActor
@Observable
final class ThemeManager {
    var current: any IslandTheme = ObsidianTheme()
}
