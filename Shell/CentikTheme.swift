import SwiftUI

/// Çentik tasarım sistemi sabitleri.
/// Kaynak: docs/06-tasarim-dili-ve-arayuz-sistemi.md §2–§3, §7.
enum CentikTheme {
    // MARK: - Renkler
    static let base = Color(red: 7 / 255, green: 9 / 255, blue: 14 / 255)
    static let card = Color(red: 17 / 255, green: 21 / 255, blue: 34 / 255)
    static let border = Color(red: 30 / 255, green: 41 / 255, blue: 59 / 255)
    static let primary = Color(red: 0 / 255, green: 102 / 255, blue: 255 / 255)
    static let accent = Color(red: 0 / 255, green: 180 / 255, blue: 255 / 255)
    static let accentSoft = Color(red: 56 / 255, green: 189 / 255, blue: 248 / 255)
    static let textPrimary = Color.white
    static let textMuted = Color(red: 148 / 255, green: 163 / 255, blue: 184 / 255)

    /// Kart iç kenarlığı (§2.1): 1px rgba(255,255,255,0.07)
    static let cardInnerStroke = Color.white.opacity(0.07)
    /// Üst speküler yansıma (§2.1): rgba(255,255,255,0.18)
    static let specularRim = Color.white.opacity(0.18)
    /// Kart hover aydınlanması (§5.3): rgba(255,255,255,0.05)
    static let hoverWash = Color.white.opacity(0.05)

    // MARK: - Köşe yarıçapları
    static let cardRadius: CGFloat = 16
    static let pillRadius: CGFloat = 16

    // MARK: - 8pt ızgara (§7)
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24

    // MARK: - Yay fiziği (§4.1)
    static let expandSpring = Animation.spring(response: 0.34, dampingFraction: 0.76)
    static let hoverSpring = Animation.spring(response: 0.26, dampingFraction: 0.82)
    static let magneticSpring = Animation.spring(response: 0.20, dampingFraction: 0.65)
}
