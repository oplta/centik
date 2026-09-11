# Çentik – Teknik Mimari Belgesi

**Dil:** Swift 6.3+ (Strict Concurrency Enabled)  
**Kullanıcı Arayüzü:** SwiftUI + AppKit Hibrit (`NSPanel`)  
**Hedef Platform:** macOS 14.0+ (Sonoma, Sequoia, Tahoe)  
**Mimari Model:** Event-Driven, Local-First, Zero-Polling  

---

## 1. Mimari Genel Bakış

Çentik'in teknik omurgası, macOS'in pencere yönetim sistemi (`AppKit / CoreGraphics`) ile SwiftUI'ın modern durum yönetimini (State Management) birleştiren yüksek performanslı bir panel motoru üzerine kuruludur.

```
+-------------------------------------------------------------+
|                      Çentik UI Katmanı                       |
|   (SwiftUI: NotchContainerView, FileShelfView, NowPlaying)  |
+-------------------------------------------------------------+
                              |
                              v
+-------------------------------------------------------------+
|                     Shell & Pencere                         |
|   (NSPanel: Non-activating, .screenSaver level, All Spaces) |
+-------------------------------------------------------------+
                              |
                              v
+-------------------------------------------------------------+
|                 Olay Yöneticileri (Event-Driven)            |
|   - Media: DistributedNotificationCenter                    |
|   - Pano: NSPasteboard.changeCount                          |
|   - Raf: NSDraggingDestination + FSEvents                   |
|   - Ekran: NSScreen.safeAreaInsets Observer                 |
+-------------------------------------------------------------+
                              |
                              v
+-------------------------------------------------------------+
|                      Yerel Çekirdek                         |
|   (SettingsStore, SQLite / Local Cache, Hotkey Listener)    |
+-------------------------------------------------------------+
```

---

## 2. Pencere ve Ekran Yönetimi (NSPanel)

Standart bir `NSWindow` odaklandığında diğer pencereleri arka plana atar ve tam ekran uygulamalarda görünmez hale gelir. Çentik, işletim sisteminin doğal bir parçası gibi davranmak için özel bir `NSPanel` alt sınıfı (`NotchPanel`) kullanır:

```swift
final class NotchPanel: NSPanel {
    init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.nonactivatingPanel, .borderless],
            backing: .buffered,
            defer: false
        )
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = false
        self.level = .mainMenu + 3 // Menü bar üstü; screenSaver seviyesinde hover gelmez
        self.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary,
            .stationary,
            .ignoresCycle
        ]
        self.isMovableByWindowBackground = false
    }
    
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}
```

### Çentik ve Ekran Tespiti (Screen Detection)
* **Çentikli Ekran:** `NSScreen.auxiliaryTopLeftArea` ve `auxiliaryTopRightArea` genişlikleri toplamı ekran genişliğinden küçükse çentik var demektir (bkz. `Shell/ScreenManager.swift`). `safeAreaInsets` iOS API'sidir, macOS'ta kullanılmaz.
* **Hap Modu (Non-notch Fallback):** Harici bir monitöre geçildiğinde veya çentiksiz bir Mac'te uygulama otomatik olarak `ScreenManager` üzerinden yüzen hap (floating pill) moduna geçer.

---

## 3. Sıfır Pil İlkesi (Event-Driven vs. Polling)

Rakiplerin en büyük hatası (NotchNook'un %8-12 idle CPU harcaması), sürekli çalışan `Timer` döngüleri ile durumu kontrol etmeleridir. Çentik'te **asla sürekli timer çalışmaz**.

1. **Now Playing Bildirimleri:**
   * Polling yapılmaz.
   * `DistributedNotificationCenter.default().addObserver(...)` ile `com.apple.Music.playerInfo` ve `com.spotify.client.PlaybackStateChanged` sistem bildirimleri pasif olarak dinlenir.
2. **Pano Geçmişi:**
   * Sonsuz döngüde pasteboard okunmaz.
   * Yalnızca `NSPasteboard.general.changeCount` değeri değiştiğinde olay tetiklenir ve yeni girdi işlenir.
3. **Dosya Rafı (FileShelf):**
   * Fare ile bir dosya çentik sınırına girdiğinde (`NSDraggingDestination.draggingEntered`) panel görünür hale gelir; bırakma tamamlandığında veya iptal edildiğinde işlem sonlanır.
   * Dosyaların silinmesi veya taşınması durumunda `FSEvents` API'si ile bildirim alınır.

---

## 4. Klasör ve Modül İskeleti

Kaynak kod yapısı aşağıdaki modüler mimariyi takip eder:

```
./ (repo kökü = Centik/)
├── App/
│   ├── CentikApp.swift            # Uygulama giriş noktası (LSUIElement = true)
│   └── AppDelegate.swift          # Menü bar durumu ve yaşam döngüsü
├── Shell/
│   ├── NotchPanel.swift           # Özel NSPanel yapılandırması
│   ├── NotchViewModel.swift       # Ada boyutu, hover, durum yönetimi
│   ├── NotchContainerView.swift   # SwiftUI ana cam kapsül
│   └── ScreenManager.swift        # Ekran değişimi ve çentik tespiti
├── Features/
│   ├── FileShelf/                 # Dosya rafı (Sürükle-bırak, AirDrop, pinleme)
│   │   ├── FileShelfManager.swift
│   │   ├── FileShelfView.swift
│   │   └── FileItem.swift
│   ├── NowPlaying/                # Medya kontrolü (Music, Spotify)
│   │   ├── NowPlayingManager.swift
│   │   └── NowPlayingView.swift
│   ├── HUD/                       # Ses ve parlaklık göstergesi
│   │   ├── HUDManager.swift
│   │   └── HUDView.swift
│   ├── Clipboard/                 # 30 öğelik yerel pano
│   │   ├── ClipboardManager.swift
│   │   └── ClipboardView.swift
│   └── CalendarChip/              # Sıradaki toplantı ve tek tık bağlantı
│       ├── CalendarManager.swift
│       └── CalendarChipView.swift
└── Core/
    ├── DesignSystem/              # Renkler, cam efektleri, yay animasyonları
    │   ├── Colors.swift
    │   └── GlassModifier.swift
    ├── Storage/                   # SQLite / UserDefaults yerel saklama
    ├── Hotkey/                    # Global kısayol dinleyici
    └── Utilities/
```

---

## 5. İzinler ve Güvenlik Modeli

* **LSUIElement:** `Info.plist` içinde `LSUIElement = YES` olarak ayarlanır. Dock'ta gereksiz ikon oluşturmaz, yalnızca çentik ve isteğe bağlı menü çubuğu simgesi üzerinden çalışır.
* **Sandbox & Yetkiler:**
  * v1 için Apple Calendar erişimi (`NSCalendarsUsageDescription`) gereklidir.
  * Ekran kaydı (Screen Recording) ve Mikrofon izni v1'de **kesinlikle istenmez**.
  * Kullanıcı verileri yerel SQLite veritabanında tutulur, dışarıya hiçbir telemetri veya ağ isteği gönderilmez.
