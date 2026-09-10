# Çentik – Ürün ve Özellik Spesifikasyonu (v1 Spec)

Bu belge, Çentik'in v1 MVP sürümünde yer alacak 6 temel özelliği ve bunların kullanıcı deneyimi (UX) kurallarını tanımlar.

---

## 1. v1 MVP Özellik Listesi (10 Günlük Kapsam)

Çentik v1'de amaç onlarca yarım özelliği yığmak değil; en çok kullanılan 6 özelliği kusursuz bir performans ve sıfır gecikmeyle sunmaktır:

| Modül | Görev | Tetikleyici / Etkileşim |
| :--- | :--- | :--- |
| **1. Ada İskeleti (Notch Shell)** | Ekran çentiğini sarar veya hap şeklinde yüzer | Fare üzerine gelince (0.18s hover) veya kısayol (`⌥Space`) |
| **2. Dosya Rafı (FileShelf)** | Dosyaları geçici tutar, pencereler arası taşır | Dosyayı adaya sürükleyip bırakma (Drag & Drop) |
| **3. Now Playing & Medya** | Çalan parçayı gösterir, durdurur/geçer | Müzik çalarken sol/sağ ada kanatlarında minyatür durum |
| **4. Sistem HUD** | Ses, ekran ve klavye ışığı seviyelerini gösterir | Ses/parlaklık tuşlarına basıldığında adadan yumuşak genişleme |
| **5. Mini Pano (Clipboard 30)** | Son 30 metin/görsel kopyasını saklar ve aratır | Ada açıldığında Pano sekmesi veya özel kısayol (`⌥V`) |
| **6. Takvim / Toplantı Çipi** | Sıradaki toplantıyı ve kalan süreyi bildirir | Toplantıya 15 dk kala sağ kanatta zarif çip |

---

## 2. Modül Detayları ve Kullanıcı Senaryoları

### 1. Ada İskeleti (Notch Shell)
* **Algılama:** Ekran çentiği varsa çentiğin tam altına ve yanlarına yapışan cam ada (OLED derin modda `#07090E`, elektrik mavisi vurgular `#0066FF`).
* **Hap Modu (Pill Mode):** Çentiksiz ekranlarda (harici monitör veya M1 Air) menü çubuğunun hemen altında süzülen 80x28px boyutlarında zarif bir kapsül.
* **Açılma & Kapanma:**
  * Fare çentik bölgesine girdiğinde 0.18 saniye gecikmeyle (yanlışlıkla açılmayı önleyen sönümleme, bkz. `06-tasarim-dili` §4.2) aşağıya doğru 60fps akıcı yay animasyonuyla genişler.
  * Fare adadan çıktığında 0.35 saniye sonra kapanır.
  * Panel dışına tıklanınca 0.35s sönümlemeyle kapanır; başlıktaki güç düğmesi uygulamayı kapatır.
  * Tam ekran (Full Screen) uygulamalara geçildiğinde çentik otomatik olarak gizlenir.
  * Ekran kaydı ve ekran görüntüsü alırken ada görünmez yapılır (`sharingType = .none`).

### 2. Dosya Rafı (FileShelf) – "Bırak, Dursun, Geri Al"
* **Kullanım Amacı:** Masaüstünden Finder'a, Finder'dan Slack/Mail'e dosya taşırken pencereler arasında kaybolmayı engeller.
* **Sürükle-Bırak:**
  * Kullanıcı herhangi bir dosyayı çentiğe doğru sürüklediğinde ada genişleyerek bir "bırakma alanı" (drop zone) açar.
  * Dosya bırakıldığında adada küçük bir kart olarak saklanır (Dosya adı, tür ikonu, boyutu).
* **Eylemler:**
  * **Taşıma:** Dosyayı raftan sürükleyip hedef pencereye (tarayıcı, Slack vb.) bırakma.
  * **Kopyalama:** `⌥ (Option)` tuşuna basarak sürükleme.
  * **AirDrop:** Dosya kartının üzerindeki AirDrop ikonuna tek tıkla paylaşım menüsünü açma.
  * **Pinleme:** Sürekli kullanılan dosyaları (örneğin imza, logo, şablon) rafta kalıcı sabitleme.
  * **Hepsini Temizle:** Tek tıkla geçici rafı boşaltma.

### 3. Now Playing & Medya
* **Entegrasyon:** Apple Music ve Spotify ile sıfır gecikmeli senkronizasyon.
* **Durumlar:**
  * *Kompakt Durum:* Çentik kapalıyken sol tarafta minik albüm kapağı, sağ tarafta canlı minyatür ses dalgası (waveform).
  * *Genişletilmiş Durum:* Şarkı adı, sanatçı, albüm kapağı, Önceki / Oynat-Duraklat / Sonraki butonları, 15 saniye ileri/geri sarma çubuğu.
* **Gizlilik:** Mikrofon izni gerektirmez, doğrudan sistem medya bildirimlerini (`DistributedNotification`) dinler.

### 4. Sistem HUD (Volume & Brightness)
* **Hedef:** macOS'in ekranın tam ortasını kapatan hantal kare ses/parlaklık göstergesini kaldırmak.
* **Davranış:**
  * Kullanıcı ses veya ekran parlaklığı tuşuna bastığında çentik aşağı doğru 14px uzar ve içinde modern bir yatay bar belirir.
  * Tuşa basma bittikten 1 saniye sonra çentik eski boyutuna pürüzsüzce geri döner.
  * "Rahatsız Etmeyin" (Focus Mode) açıkken HUD bildirimleri sessizce bastırılabilir.

### 5. Mini Pano (Clipboard History)
* **Kapsam:** Son 30 kopyalanan metin, link ve görsel.
* **Arama:** Klavyeden yazmaya başlandığı anda gerçek zamanlı filtreleme.
* **Tek Tıkla Yapıştırma:** Seçilen öğeye tıklandığında veya `Enter` basıldığında son aktif pencereye otomatik yapıştırma.
* **Güvenlik:** Şifre yöneticilerinden (1Password, Bitwarden, Keychain) kopyalanan gizli veriler panoya kaydedilmez (`org.nspasteboard.ConcealedType`).

### 6. Takvim / Toplantı Çipi
* **Davranış:** Sistem takvimini (iCloud / Google Calendar) okur.
* **Toplantı Uyarısı:** Toplantıya 15 ve 5 dakika kala çentiğin sağ köşesinde ufak bir toplantı çipi belirir: `"14:00 Tasarım İncelemesi (7 dk kaldı)"`.
* **Tek Tıkla Katılım:** Çipe tıklandığında Zoom, Google Meet, Teams veya FaceTime linki doğrudan varsayılan tarayıcıda/uygulamada açılır.

---

## 3. Yol Haritası (Boring Notch kod analizinden beslendi, 11 Eyl 2026)

Boring Notch (GPL-3.0, 120 Swift dosyası) klonlanıp incelendi. **Yasal sınır:**
kod kopyalanamaz (GPL, MIT çekirdeği kirletir); yalnızca fikir/pattern yeniden yazılır.
Detay: `docs/05 §4`.

### v0.2 — Raf gerçekten kullanışlı (sıradaki)
- [x] **DragMonitor:** global fare + drag-pasteboard ile sürükleme çentik bölgesine girince aç, çıkınca kapat (Boring `DragDetector` patterni; ilk açılışta Erişilebilirlik izni ister).
- [ ] **Çok tipli drop:** dosya + link + metin merdiveni (Boring `ShelfDropService` sırası); söz verilen dosyalar (promise) dahil.
- [ ] **Raf ızgarası:** küçük resimli kartlar (QLThumbnail), pin rozeti, sağ-tık menü (Aç / AirDrop / Sil).
- [ ] **Raftan sürükle-bırak:** dosyayı raftan Finder/Slack'e geri taşıma + QuickLook (Boşluk) önizleme.
- [ ] **Kalıcılık:** bookmark kaydet/yükle; açılışta geçersizleri temizle.

### v0.3 — Medya gerçek kontrol
- [ ] **Transport:** `MRMediaRemoteSendCommand` ile oynat/duraklat/sonraki/önceki/±15sn (AppleEvent izni gerekmez; Boring `MediaControllerProtocol` arayüzü örnek alınır).
- [ ] **İlerleme çubuğu:** süre/geçen + seek (yalnızca açık + çalarken tick; idle-%0 ilkesi korunur).
- [ ] **Uygulama ikonu + kapak:** hangi uygulamadan çaldığı rozeti.

### v0.4 — v1'i kapat (pano + HUD + takvim)
- [ ] Mini Pano 30 + `⌥V` (şifre filtresiyle; OCR yok).
- [ ] Sistem HUD (ses/parlaklık/klavye ışığı).
- [ ] Takvim çipi (tek-tık katılım; çağrı kontrolü yok).

### v2 — Pro ($19)
1. **Drop-to-Convert:** HEIC→JPG/PNG, PNG sıkıştırma, çoklu görsel→PDF.
2. **On-Device Offline Dikte:** basılı tut-konuş (Apple Speech / Whisper).
3. **Pano OCR:** ekran görüntüsünde Vision ile yerel metin arama.
4. **Mini Sistem Monitörü:** istenince CPU/RAM/pil (sürekli poll yok).

### Bilerek alınMAyanlar (Boring'dan ders)
- Şarkı sözü web araması (ağ/telemetri ilkesi), Lottie bağımlılığı, kamera aynası (izin yükü),
  her-yerde singleton (`.shared` çöplüğü yerine init-enjeksiyon bizde kalır).
