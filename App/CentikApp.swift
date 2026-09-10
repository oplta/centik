import SwiftUI

/// Çentik uygulama giriş noktası.
/// Info.plist: LSUIElement = YES (Dock ikonu yok, yalnızca ada + menü çubuğu).
@main
struct CentikApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
