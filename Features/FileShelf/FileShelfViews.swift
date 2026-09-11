import AppKit
import QuickLookThumbnailing
import SwiftUI

/// Küçük resim: QLThumbnail ile dosya önizlemesi (izin gerektirmez).
private struct ThumbnailView: View {
    let item: FileItem

    @State private var image: NSImage?

    var body: some View {
        Group {
            if let image {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Image(systemName: "doc.fill")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .task(id: item.id) {
            image = await makeThumbnail()
        }
    }

    private func makeThumbnail() async -> NSImage? {
        guard let url = item.resolveURL() else { return nil }
        let accessing = url.startAccessingSecurityScopedResource()
        defer { if accessing { url.stopAccessingSecurityScopedResource() } }
        return await withCheckedContinuation { continuation in
            let scale = NSScreen.main?.backingScaleFactor ?? 2
            let request = QLThumbnailGenerator.Request(
                fileAt: url,
                size: CGSize(width: 112, height: 112),
                scale: scale,
                representationTypes: .thumbnail
            )
            QLThumbnailGenerator.shared.generateBestRepresentation(for: request) { rep, _ in
                continuation.resume(returning: rep?.nsImage)
            }
        }
    }
}

/// Raf kartı: tıkla-aç, sağ-tık menü (Sabitle / Finder'da Göster / Kaldır).
struct FileCard: View {
    let theme: any IslandTheme
    let shelf: FileShelfManager
    let item: FileItem

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isHovered = false

    var body: some View {
        Button { shelf.open(id: item.id) } label: {
            VStack(spacing: CentikTheme.xs) {
                ZStack(alignment: .topTrailing) {
                    ThumbnailView(item: item)
                        .frame(width: 56, height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    if item.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(theme.accentSoft)
                            .padding(5)
                            .accessibilityHidden(true)
                    }
                }
                Text(item.name)
                    .font(.system(size: 9))
                    .foregroundColor(theme.textPrimary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .frame(width: 72)
            }
            .frame(width: 80, height: 100)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isHovered ? theme.hoverWash : .clear)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(theme.card)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isHovered ? theme.primary.opacity(0.6) : theme.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isHovered && !reduceMotion ? 1.03 : 1.0)
        .animation(reduceMotion ? nil : CentikTheme.hoverSpring, value: isHovered)
        .onHover { isHovered = $0 }
        .contextMenu {
            Button(item.isPinned ? "Pini Kaldır" : "Sabitle") {
                shelf.togglePin(id: item.id)
            }
            Button("Finder'da Göster") {
                shelf.reveal(id: item.id)
            }
            Divider()
            Button("Raftan Çıkar", role: .destructive) {
                shelf.remove(id: item.id)
            }
        }
        .accessibilityLabel(item.name)
        .accessibilityHint("Açmak için etkinleştirin")
    }
}

/// Raf şeridi: boşken bırakma daveti, doluyken yatay kart listesi.
struct ShelfStrip: View {
    let theme: any IslandTheme
    let shelf: FileShelfManager

    var body: some View {
        if shelf.items.isEmpty {
            VStack(spacing: CentikTheme.xs + 2) {
                Image(systemName: "tray.and.arrow.down")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(theme.primary)
                    .accessibilityHidden(true)
                Text("Dosya Bırak")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(theme.textPrimary)
                Text("Bırak, dursun")
                    .font(.system(size: 9))
                    .foregroundColor(theme.textMuted)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 104)
            .background(
                RoundedRectangle(cornerRadius: CentikTheme.cardRadius, style: .continuous)
                    .fill(theme.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: CentikTheme.cardRadius, style: .continuous)
                    .stroke(theme.cardInnerStroke, lineWidth: 1)
                    .padding(0.5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: CentikTheme.cardRadius, style: .continuous)
                    .stroke(theme.border, lineWidth: 1)
            )
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Dosya rafı boş. Dosya bırakın.")
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CentikTheme.sm) {
                    ForEach(shelf.items) { item in
                        FileCard(theme: theme, shelf: shelf, item: item)
                    }
                }
                .padding(.horizontal, 2)
            }
            .frame(height: 104)
            .accessibilityLabel("Dosya rafı, \(shelf.items.count) dosya")
        }
    }
}
