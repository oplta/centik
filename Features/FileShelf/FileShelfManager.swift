import AppKit
import Foundation

/// Raftaki tek dosya: yer imi (bookmark) ile yeniden başlatmalara dayanır.
struct FileItem: Identifiable, Sendable {
    let id: UUID
    let bookmark: Data
    let name: String
    var isPinned: Bool

    init(url: URL, isPinned: Bool = false) throws {
        self.id = UUID()
        self.bookmark = try url.bookmarkData(
            options: .withSecurityScope,
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )
        self.name = url.lastPathComponent
        self.isPinned = isPinned
    }

    /// Kalıcılıktan yükleme: bayat/çözümlenemeyen yer imleri elenir.
    /// Bayat bookmark throw eder → öğe sessizce düşer (açılış temizliği).
    init(bookmark: Data, isPinned: Bool) throws {
        var stale = false
        let url = try URL(
            resolvingBookmarkData: bookmark,
            options: .withSecurityScope,
            relativeTo: nil,
            bookmarkDataIsStale: &stale
        )
        guard !stale else { throw CocoaError(.fileReadInvalidFileName) }
        self.id = UUID()
        self.bookmark = bookmark
        self.name = url.lastPathComponent
        self.isPinned = isPinned
    }

    /// Bookmark'ı çözümler; dosya taşınmış/silinmişse nil döner.
    func resolveURL() -> URL? {
        var stale = false
        return try? URL(
            resolvingBookmarkData: bookmark,
            options: .withSecurityScope,
            relativeTo: nil,
            bookmarkDataIsStale: &stale
        )
    }
}

/// Dosya rafı: bırakılan dosyaları geçici tutar, pinliler kalıcıdır.
/// Ücretsiz katman: pinsiz en fazla 5 slot (docs/01 §4).
@MainActor
@Observable
final class FileShelfManager {
    static let freeSlotLimit = 5

    private(set) var items: [FileItem] = []

    private static let storeKey = "centik.shelf.v1"

    private struct StoredItem: Codable {
        var bookmark: Data
        var pinned: Bool
    }

    init() {
        load()
    }

    /// Yeniden başlatmalarda rafı geri yükler; geçersizler elenir.
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: Self.storeKey),
              let stored = try? JSONDecoder().decode([StoredItem].self, from: data)
        else { return }
        items = stored.compactMap { try? FileItem(bookmark: $0.bookmark, isPinned: $0.pinned) }
    }

    private func save() {
        let stored = items.map { StoredItem(bookmark: $0.bookmark, pinned: $0.isPinned) }
        UserDefaults.standard.set(try? JSONEncoder().encode(stored), forKey: Self.storeKey)
    }

    var subtitle: String {
        items.isEmpty ? "Bırak, dursun" : "\(items.count) dosya"
    }

    func add(url: URL) {
        // Aynı dosya zaten raftaysa tekrar ekleme.
        let path = url.path
        guard !items.contains(where: { $0.resolveURL()?.path == path }) else { return }
        // Slot doluysa en eski pinsiz öğeyi düşür.
        if unpinnedCount >= Self.freeSlotLimit,
           let oldest = items.firstIndex(where: { !$0.isPinned })
        {
            items.remove(at: oldest)
        }
        guard let item = try? FileItem(url: url) else { return }
        items.append(item)
        save()
    }

    func remove(id: FileItem.ID) {
        items.removeAll { $0.id == id }
        save()
    }

    func togglePin(id: FileItem.ID) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        items[index].isPinned.toggle()
        save()
    }

    func clearUnpinned() {
        items.removeAll { !$0.isPinned }
        save()
    }

    /// Kart tıklaması: dosyayı varsayılan uygulamayla açar.
    /// Çözümlenemeyen (silinmiş) öğe raftan düşer.
    func open(id: FileItem.ID) {
        guard let item = items.first(where: { $0.id == id }) else { return }
        guard withAccess(item, { NSWorkspace.shared.open($0) }) != nil else {
            items.removeAll { $0.id == id }
            save()
            return
        }
    }

    /// Sağ-tık: Finder'da gösterir.
    func reveal(id: FileItem.ID) {
        guard let item = items.first(where: { $0.id == id }) else { return }
        withAccess(item) { NSWorkspace.shared.activateFileViewerSelecting([$0]) }
    }

    /// Bookmark çözümleme + sandbox kapsamı.
    /// Not: korumalı moda geçilirse open sonrası erişim hedef uygulamaya
    /// powerbox ile taşınır; bu çağrı yalnızca çözümleme anını kapsar.
    private func withAccess<T>(_ item: FileItem, _ body: (URL) -> T) -> T? {
        guard let url = item.resolveURL() else { return nil }
        let accessing = url.startAccessingSecurityScopedResource()
        defer { if accessing { url.stopAccessingSecurityScopedResource() } }
        return body(url)
    }

    private var unpinnedCount: Int { items.filter { !$0.isPinned }.count }
}
