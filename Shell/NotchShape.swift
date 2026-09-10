import SwiftUI

/// Apple donanım çentiği ve menü bar omuz kavislerini (shoulders) birebir üreten dinamik şekil.
/// Kaynak referansı: DynamicNotchKit & boring.notch bezier eğri modeli.
struct NotchShape: Shape {
    var topCornerRadius: CGFloat = 6
    var bottomCornerRadius: CGFloat = 14

    // Not: @Animatable makrosu bu toolchain'de plugin eksikliğinden derlenmiyor
    // (doğrulandı: SwiftUIMacros not found). Manuel eşdeğeri aynı sentezi üretir.
    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(topCornerRadius, bottomCornerRadius) }
        set {
            topCornerRadius = newValue.first
            bottomCornerRadius = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // 1. Sol üst tavan başlangıcı (menü bar ile birleşme noktası)
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))

        // 2. Sol üst omuz kavisi (dışa doğru yumuşak menü bar bağlantısı)
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + topCornerRadius, y: rect.minY + topCornerRadius),
            control: CGPoint(x: rect.minX + topCornerRadius, y: rect.minY)
        )

        // 3. Sol dikey kenar
        path.addLine(to: CGPoint(x: rect.minX + topCornerRadius, y: rect.maxY - bottomCornerRadius))

        // 4. Sol alt köşe kavisi
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + topCornerRadius + bottomCornerRadius, y: rect.maxY),
            control: CGPoint(x: rect.minX + topCornerRadius, y: rect.maxY)
        )

        // 5. Alt düz kenar
        path.addLine(to: CGPoint(x: rect.maxX - topCornerRadius - bottomCornerRadius, y: rect.maxY))

        // 6. Sağ alt köşe kavisi
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - topCornerRadius, y: rect.maxY - bottomCornerRadius),
            control: CGPoint(x: rect.maxX - topCornerRadius, y: rect.maxY)
        )

        // 7. Sağ dikey kenar
        path.addLine(to: CGPoint(x: rect.maxX - topCornerRadius, y: rect.minY + topCornerRadius))

        // 8. Sağ üst omuz kavisi (sağ menü bara bağlanış)
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY),
            control: CGPoint(x: rect.maxX - topCornerRadius, y: rect.minY)
        )

        // 9. Üst tavan çizgisi
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))

        return path
    }
}
