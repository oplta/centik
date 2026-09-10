# Çentik – Ürün ve Özellik Spesifikasyonu (v1 Spec)

Bu belge, Çentik'in v1 MVP sürümünde yer alacak 6 temel özelliği ve bunların kullanıcı deneyimi (UX) kurallarını tanımlar.

---

## 1. v1 MVP Özellik Listesi (10 Günlük Kapsam)

Çentik v1'de amaç onlarca yarım özelliği yığmak değil; en çok kullanılan 6 özelliği kusursuz bir performans ve sıfır gecikmeyle sunmaktır:

| Modül | Görev | Tetikleyici / Etkileşim |
| :--- | :--- | :--- |
| **1. Ada İskeleti (Notch Shell)** | Ekran çentiğini sarar veya hap şeklinde yüzer | Fare üzerine gelince (0.2s hover) veya kısayol (`⌥Space`) |
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
  * Fare çentik bölgesine girdiğinde 0.2 saniye gecikmeyle (yanlışlıkla açılmayı önleyen sönümleme) aşağıya doğru 60fps akıcı yay animasyonuyla genişler.
  * Fare adadan çıktığında 0.4 saniye sonra kapanır.
  * `Esc` tuşuna basıldığında anında kapanır.
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

## 3. Gelecek Sürümler (v2 Yol Haritası)

Aşağıdaki özellikler v1 MVP tamamlanıp kullanıcı geri bildirimleri toplandıktan sonra eklenecektir:
1. **Drop-to-Convert (Dosya Dönüştürücü):**
   * HEIC → JPG / PNG dönüştürme
   * PNG görsel sıkıştırma
   * Çoklu görselleri tek tıkla PDF yapma
2. **On-Device Offline Dikte:**
   * Kısayola basılı tutarak konuşulanı imlecin olduğu yere yazma (Apple Speech / Whisper).
3. **Gelişmiş Pano OCR:**
   * Ekran görüntüsü içindeki metinleri Apple Vision Framework ile yerel olarak arayabilme.
4. **Mini Sistem Monitörü:**
   * Çentikte sadece istendiğinde görünen CPU, RAM ve pil sıcaklığı göstergesi.
