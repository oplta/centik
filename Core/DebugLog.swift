import Foundation

/// Geçici saha teşhisi: panel/olay akışını dosyaya yazar.
/// Ekran görüntüsü almaz, piksel okumaz — yalnızca durum satırları.
/// Teşhis bitince çağrılar silinecek.
enum DebugLog {
    private static let url = FileManager.default.temporaryDirectory
        .appendingPathComponent("centik-debug.log")

    static func log(_ message: String) {
        let line = "\(Date()): \(message)\n"
        guard let data = line.data(using: .utf8) else { return }
        if FileManager.default.fileExists(atPath: url.path) {
            guard let handle = try? FileHandle(forWritingTo: url) else { return }
            try? handle.seekToEnd()
            try? handle.write(contentsOf: data)
            try? handle.close()
        } else {
            try? data.write(to: url)
        }
    }
}
