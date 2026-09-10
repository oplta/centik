import AppKit
import SwiftUI
import UniformTypeIdentifiers

/// Sistem buzlu cam malzemesi — yalnızca macOS 26 öncesi fallback.
/// macOS 26+ yolunda natif `.glassEffect()` kullanılır.
struct VisualEffectBlur: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .hudWindow
        view.blendingMode = .behindWindow
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}

/// Çentik ana cam ada arayüzü.
/// Bkz. docs/06-tasarim-dili-ve-arayuz-sistemi.md
struct NotchContainerView: View {
    let viewModel: NotchViewModel
    let screenManager: ScreenManager
    let shelf: FileShelfManager
    let nowPlaying: NowPlayingManager
    let themes: ThemeManager

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    /// Sürükle-bırak manyetik hedef vurgusu (§5.2: kesikli #0066FF çerçeve + %3 büyüme)
    @State private var isDropTarget = false

    /// Efektler kapalıysa (Reduce Transparency) düz opak zemin kullanılır.
    private var useGlass: Bool { !reduceTransparency }
    /// Aktif tema (Pro temalar ThemeManager üzerinden değişir).
    private var theme: any IslandTheme { themes.current }
    /// Hareket kapalıysa yaylar anında duruma geçer.
    private var motion: Animation? { reduceMotion ? nil : CentikTheme.hoverSpring }

    private var currentWidth: CGFloat {
        viewModel.currentWidth(
            hasNotch: screenManager.hasNotch,
            notchWidth: screenManager.notchWidth
        )
    }

    private var currentHeight: CGFloat {
        viewModel.currentHeight(
            hasNotch: screenManager.hasNotch,
            notchHeight: screenManager.notchHeight
        )
    }

    /// Kapalı durum nokta parlaklığı: sürekli nabız YOK (idle-%0 ilkesi);
    /// yalnızca hover/açık durumda canlanır.
    private var statusOpacity: Double {
        if reduceMotion { return 1.0 }
        return (viewModel.isHovered || viewModel.isExpanded) ? 1.0 : 0.55
    }

    var body: some View {
        VStack(spacing: 0) {
            islandBody
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .ignoresSafeArea()
    }

    private var islandBody: some View {
        ZStack(alignment: .top) {
            islandBackground

            if viewModel.isExpanded {
                expandedContent
                    .transition(
                        reduceMotion
                            ? .opacity
                            : .opacity.combined(with: .scale(scale: 0.96, anchor: .top))
                    )
            } else {
                collapsedContent
                    .transition(.opacity)
            }
        }
        .frame(width: currentWidth, height: currentHeight)
        // Manyetik tepki: dosya yaklaşınca %3 büyü (§5.2)
        .scaleEffect(isDropTarget && !reduceMotion ? 1.03 : 1.0, anchor: .top)
        .animation(reduceMotion ? nil : CentikTheme.magneticSpring, value: isDropTarget)
        .contentShape(Rectangle())
        .onTapGesture {
            if !viewModel.isExpanded {
                viewModel.expand()
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityAction(.escape) {
            viewModel.collapse()
        }
        .onHover { hovering in
            viewModel.onHoverChanged(hovering)
        }
        .onDrop(of: [.fileURL], isTargeted: $isDropTarget) { providers in
            for provider in providers {
                _ = provider.loadObject(ofClass: URL.self) { url, _ in
                    guard let url else { return }
                    Task { @MainActor in shelf.add(url: url) }
                }
            }
            viewModel.performHaptic()
            return true
        }
        // Sürükleme sırasında hover olayı gelmez; ada drop-hedefiyle açılıp kapanır.
        .onChange(of: isDropTarget) { _, targeted in
            if targeted {
                viewModel.expand()
            } else {
                viewModel.onHoverChanged(false)
            }
        }
        // Ada gövdesi altında yumuşak derinlik gölgesi
        .shadow(
            color: .black.opacity(viewModel.isExpanded ? 0.45 : 0.25),
            radius: viewModel.isExpanded ? 24 : 8,
            y: 8
        )
    }

    // MARK: - Ada Gövdesi (§2.1)

    @ViewBuilder
    private var islandBackground: some View {
        if screenManager.hasNotch {
            notchGlass(
                shape: NotchShape(
                    topCornerRadius: viewModel.isExpanded ? 10 : 6,
                    bottomCornerRadius: viewModel.isExpanded ? 24 : 14
                )
            )
        } else {
            notchGlass(
                shape: RoundedRectangle(
                    cornerRadius: viewModel.isExpanded ? 24 : CentikTheme.pillRadius,
                    style: .continuous
                )
            )
        }
    }

    /// Cam gövde: macOS 26+ natif Liquid Glass, öncesi NSVisualEffectView,
    /// Reduce Transparency durumunda düz opak zemin.
    private func notchGlass<S: Shape>(shape: S) -> some View {
        ZStack {
            if useGlass {
                if #available(macOS 26, *) {
                    Color.clear
                        .glassEffect(.regular, in: shape)
                } else {
                    shape.fill(theme.base.opacity(0.88))
                    VisualEffectBlur()
                        .clipShape(shape)
                        .opacity(0.85)
                }
            } else {
                shape.fill(theme.base)
            }
            // Üst speküler yansıma çizgisi
            VStack {
                shape
                    .stroke(theme.specularRim, lineWidth: 1)
                    .mask(
                        LinearGradient(
                            colors: [.white, .clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
                Spacer(minLength: 0)
            }
            shape.stroke(theme.border, lineWidth: 1.5)
            // Drop hedefinde kesikli elektrik mavisi çerçeve
            if isDropTarget {
                shape.stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                    .foregroundStyle(theme.primary)
            }
        }
    }

    // MARK: - Kapalı Durum (§5.1)

    private var collapsedContent: some View {
        VStack(spacing: 0) {
            if !screenManager.hasNotch {
                // Hap modu boşta gizli; nokta yalnızca müzik çalarken parlar (§5.1).
                if nowPlaying.isPlaying {
                    Circle()
                        .fill(theme.primary)
                        .frame(width: 6, height: 6)
                        .opacity(statusOpacity)
                        .animation(motion, value: statusOpacity)
                        .accessibilityHidden(true)
                        .frame(maxHeight: .infinity)
                        .padding(.horizontal, 12)
                        .accessibilityElement(children: .combine)
                        .accessibilityAddTraits(.isButton)
                        .accessibilityLabel("Çentik")
                        .accessibilityHint("Bilgi panelini açmak için etkinleştirin")
                        .accessibilityAction {
                            viewModel.expand()
                        }
                }
            } else {
                Spacer()
                // Alt aktivite çizgisi: hep görünür, hover'da uzar.
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [theme.primary, theme.accentSoft],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: viewModel.isHovered ? 52 : 38, height: 2.5)
                    .animation(motion, value: viewModel.isHovered)
                    .padding(.bottom, 2)
                    .shadow(color: theme.primary.opacity(0.5), radius: 3)
                    .accessibilityHidden(true)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Genişletilmiş Panel (§5.1: 380–420px, dinamik 180–240px)

    private var expandedContent: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                Spacer()
                QuitButton(theme: theme) {
                    viewModel.quit()
                }
            }
            .padding(.horizontal, CentikTheme.md)
            .padding(.top, 14)
            .padding(.bottom, 10)

            Divider()
                .background(theme.border)
                .padding(.horizontal, 12)

            HStack(spacing: CentikTheme.md) {
                ModuleCard(
                    theme: theme,
                    icon: "tray.and.arrow.down",
                    artwork: nil,
                    iconColor: theme.primary,
                    title: shelf.items.isEmpty ? "Dosya Bırak" : "\(shelf.items.count) dosya",
                    subtitle: shelf.items.first?.name ?? "Bırak, dursun",
                    accessibilityLabel: "Dosya rafı",
                    accessibilityHint: "Dosyaları geçici tutmak için bırakın",
                    onTap: { viewModel.performHaptic() }
                )
                ModuleCard(
                    theme: theme,
                    icon: nowPlaying.isPlaying ? "waveform" : "music.note",
                    artwork: nowPlaying.artwork,
                    iconColor: theme.accent,
                    title: nowPlaying.headline,
                    subtitle: nowPlaying.subline,
                    accessibilityLabel: "Şimdi çalıyor",
                    accessibilityHint: "Medya kontrollerini açar",
                    onTap: { viewModel.performHaptic(.generic) }
                )
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)

            // Alt kısayol ipuçları (8pt ızgara)
            HStack(spacing: CentikTheme.md) {
                ShortcutHint(theme: theme, keys: "⌥Space", label: "aç/kapa")
                ShortcutHint(theme: theme, keys: "⌥V", label: "pano")
                Spacer()
                Text("Hesap yok · Bulut yok")
                    .font(.system(size: 9))
                    .foregroundColor(theme.textMuted.opacity(0.7))
            }
            .padding(.horizontal, CentikTheme.md)
            .padding(.top, CentikTheme.sm)
            .padding(.bottom, 14)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Kısayollar: Option Boşluk aç kapa, Option V pano")
        }
    }
}

// MARK: - Modül Kartı (§5.2–§5.3: #111522 zemin, 16px yarıçap, hover wash)

// Semantik kontrol: gerçek Button — klavye, VoiceOver, Switch Control ile çalışır.
private struct ModuleCard: View {
    let theme: any IslandTheme
    let icon: String
    let artwork: NSImage?
    let iconColor: Color
    let title: String
    let subtitle: String
    let accessibilityLabel: String
    let accessibilityHint: String
    let onTap: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isHovered = false

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: CentikTheme.xs + 2) {
                if let artwork {
                    Image(nsImage: artwork)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 28, height: 28)
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        .accessibilityHidden(true)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(iconColor)
                        .frame(height: 24)
                        .accessibilityHidden(true)
                }
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(theme.textPrimary)
                Text(subtitle)
                    .font(.system(size: 9))
                    .foregroundColor(theme.textMuted)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 108)
            .background(
                RoundedRectangle(cornerRadius: CentikTheme.cardRadius, style: .continuous)
                    .fill(isHovered ? theme.hoverWash : .clear)
                    .background(
                        RoundedRectangle(cornerRadius: CentikTheme.cardRadius, style: .continuous)
                            .fill(theme.card)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: CentikTheme.cardRadius, style: .continuous)
                    .stroke(theme.cardInnerStroke, lineWidth: 1)
                    .padding(0.5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: CentikTheme.cardRadius, style: .continuous)
                    .stroke(isHovered ? theme.primary.opacity(0.6) : theme.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isHovered && !reduceMotion ? 1.02 : 1.0, anchor: .center)
        .animation(
            reduceMotion ? nil : CentikTheme.hoverSpring,
            value: isHovered
        )
        .onHover { isHovered = $0 }
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
    }
}

// MARK: - Çıkış Düğmesi

/// Başlıktaki güç düğmesi: tıklanınca uygulamayı tamamen kapatır.
private struct QuitButton: View {
    let theme: any IslandTheme
    let onQuit: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: onQuit) {
            Image(systemName: "power")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(isHovered ? .red : theme.textMuted)
                .frame(width: 24, height: 24)
                .background(
                    Circle().fill(isHovered ? Color.red.opacity(0.12) : .clear)
                )
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
        .accessibilityLabel("Çentik'ten çık")
        .accessibilityHint("Uygulamayı tamamen kapatır")
    }
}

// MARK: - Kısayol İpucu

private struct ShortcutHint: View {
    let theme: any IslandTheme
    let keys: String
    let label: String

    var body: some View {
        HStack(spacing: CentikTheme.xs) {
            Text(keys)
                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                .foregroundColor(theme.accentSoft)
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(theme.textMuted)
        }
        .accessibilityHidden(true)
    }
}
