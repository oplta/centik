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
    }

    func remove(id: FileItem.ID) {
        items.removeAll { $0.id == id }
    }

    func togglePin(id: FileItem.ID) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        items[index].isPinned.toggle()
    }

    func clearUnpinned() {
        items.removeAll { !$0.isPinned }
    }

    private var unpinnedCount: Int { items.filter { !$0.isPinned }.count }
}
