# Çentik – Tasarım Dili ve Arayüz Sistemi (Design System & UI Language)

Bu belge, Çentik'in native macOS arayüzünün (UI), kullanıcı deneyiminin (UX), görsel malzemelerinin, bileşen anatomisinin ve animasyon fiziğinin resmi tasarım kurallarını belirler.

---

## 1. Tasarım Felsefesi

Çentik'in tasarım dili üç temel sütun üzerine kuruludur:

### 1.1. Gizli Donanım Entegrasyonu (Stealth Hardware Integration)
Çentik, ekrana sonradan eklenmiş yabancı bir pencere gibi durmaz; MacBook'un siyah donanım çentiğinin doğal, akıcı bir uzantısı gibi davranır. Boştayken çentiğin siyahlığında kaybolur (`#07090E`), ihtiyaç anında zarif bir ışık ve hareketle uyanır.

### 1.2. Sıvı Hassasiyet (Liquid Precision)
Bulanık, dağınık ve kirli gölgeler yerine; Apple'ın Liquid Glass dokusunu keskin mimari hatlar (1.5px hairline çerçeve) ve net basamaklı dalgalarla birleştirir. Estetik süs için değil, işlev için vardır.

### 1.3. Bak-ve-Bitir (Glanceable & Actionable)
Arayüz asla kullanıcının dikkatini çalacak karmaşık grafikler veya uzun metinler içermez. Bilgi göz ucuyla 1 saniyede taranır, eylem (dosyayı bırakma, panoyu yapıştırma, toplantıya bağlanma) tek bir hamlede tamamlanır.

---

## 2. Malzeme, Cam ve Yüzey Hiyerarşisi

Çentik arayüzü 4 katmanlı derinlik modelini kullanır:

```
[ Katman 4: Odak & Vurgu ]   -> Elektrik Mavisi Butonlar & Rozetler (#0066FF)
[ Katman 3: Etkileşim Kartı] -> Kartlar, Raf Kutuları, Pano Satırları (#111522)
[ Katman 2: Ada Gövdesi ]    -> Liquid Frosted Glass (%85 Opaklık, Blur 30px)
[ Katman 1: Ekran Tabanı ]   -> Donanım Çentiği & OLED Obsidiyen Siyahı (#07090E)
```

### 2.1. Yüzey Malzemeleri
* **Ana Gövde (Island Body):** `rgba(7, 9, 14, 0.88)` + Sistem `NSVisualEffectView` (`.behindWindow`, `.hudWindow`).
* **İç Kartlar (Container Cards):** `#111522` zemin üzerine `1px` iç kenarlık (`rgba(255, 255, 255, 0.07)`).
* **Kenarlık & Işık Yansıması:** 
  * Üst kenar (Specular Rim): `rgba(255, 255, 255, 0.18)`
  * Yan ve alt kenar (Stroke): `#1E293B` (1.5px keskin çerçeve).

---

## 3. Renk Sistemi ve Durumlar

| Durum | Renk Kodu | Kullanım Alanı | Davranış |
| :--- | :--- | :--- | :--- |
| **Zemin (Base)** | `#07090E` | Ada ana yüzeyi | Donanım çentiğiyle birebir örtüşür |
| **Kenarlık (Border)** | `#1E293B` | Kart ve panel çerçeveleri | 1.5px keskin hat |
| **Birincil (Primary)** | `#0066FF` | Aktif aksiyon, sürükleme hedefi | Hover anında parlama |
| **Vurgu (Accent)** | `#00B4FF` / `#38BDF8`| Müzik dalgası, durum rozeti | Canlı hareket göstergesi |
| **Metin (Primary Text)**| `#FFFFFF` | Başlıklar, çalan parça adı | Net okunabilirlik |
| **Metin (Muted Text)** | `#94A3B8` | Dosya boyutları, saat, ikincil bilgi | Düşük dikkat yükü |
| **Hata / Uyarı** | `#FF453A` / `#FF9F0A` | İzin eksikliği, düşük pil | Sadece gerektiğinde |

---

## 4. Hareket, Fizik ve Animasyon (Motion Physics)

Çentik'te lineer veya yapay animasyonlar **kesinlikle yasaktır**. Tüm geçişler Apple SwiftUI yay eğrileri (`Spring`) ile çalışır.

### 4.1. Yay Eğrileri (Spring Curves)
```swift
// Ada Genişleme & Açılma
.spring(response: 0.34, dampingFraction: 0.76, blendDuration: 0)

// Hover & Boyut Küçülme
.spring(response: 0.26, dampingFraction: 0.82, blendDuration: 0)

// Sürükle-Bırak Manyetik Tepki
.spring(response: 0.20, dampingFraction: 0.65, blendDuration: 0)
```

### 4.2. Zamanlama ve Sönümleme Kuralları
* **Hover Gecikmesi (Damping Delay):** Fare çentiğin üzerine geldiğinde ada hemen fırlamaz; istem dışı açılmaları önlemek için **0.18 saniye** sönümleme süresi bekler.
* **Kapanma Gecikmesi:** Fare adadan ayrıldığında **0.35 saniye** sonra yumuşakça kapanır.
* **Esc Kısayolu:** `Esc` tuşuna basıldığında bekleme olmaksızın anında (0.15s) toparlanır.

---

## 5. Bileşen Anatomisi (Component Design)

### 5.1. Ada Durumları (Island States)

1. **Kapalı Durum (Collapsed):**
   * *Notch Mac:* Çentiğin tam arkasında gizlidir. Yalnızca müzik çalıyorsa sağ/sol kanatta 4px minyatür canlı aktivite noktası parlar.
   * *Hap Modu (Non-notch):* Menü barının altında süzülen 80x28px boyutunda hap.
2. **Önizleme Durumu (Peek):**
   * Fare yaklaştığında ada 24px aşağı sarkar ve içerik ipucu verir.
3. **Tam Açık Durum (Expanded Panel):**
   * Genişlik: 380px – 420px
   * Yükseklik: İçeriğe göre dinamik (180px – 240px)
   * Köşe Yarıçapı: `rx = 28px` (Üstte çentik omuz kavisleri).

### 5.2. Dosya Rafı (FileShelf) Bileşeni
* **Bırakma Alanı (Drop Zone):** Dosya yaklaştığında çentik paneli sınırlarında kesikli Elektrik Mavisi (`#0066FF`) manyetik çerçeve belirir. Panel boyutu %3 büyür (`scale: 1.03`).
* **Dosya Kartı (File Item):**
  * Boyut: 96px x 108px dikey kart.
  * Köşe Yarıçapı: 16px.
  * Zemin: `#111522`.
  * İkon: Dosya türüne göre Apple SF Symbol veya görsel küçük resmi (thumbnail).
  * Hover: Üst köşede tek tıkla AirDrop veya Çöp Kutusu ikonu görünür.

### 5.3. Mini Pano (Clipboard Row) Bileşeni
* **Satır Yüksekliği:** 38px.
* **Tipografi:** Monospace SF Pro (kod parçacıkları için), SF Pro Text (metin için).
* **Hover:** Arka plan hafif aydınlanır (`rgba(255, 255, 255, 0.05)`), sağ kenarda Elektrik Mavisi `↵` (Enter) yapıştırma rozeti belirir.

### 5.4. Sistem HUD Bileşeni
* **Form:** Ada alt kenarından aşağı sarkan 14px yüksekliğinde, 160px genişliğinde minimalist bar.
* **Dolgu:** Elektrik mavisi (`#0066FF`) canlı dolgu barı.
* **Kaybolma:** Tuşa basma bittikten 1.0 saniye sonra pürüzsüzce çentiğe geri çekilir.

---

## 6. Haptik ve Ses Geri Bildirimi

Kullanıcı deneyimi yalnızca görsel değil, dokunsal olarak da desteklenir:
* **Dosya Adaya Bırakıldığında:** Trackpad üzerinden yumuşak manyetik tık (`NSHapticFeedbackManager.FeedbackPattern.alignment`).
* **Pano Öğesi Kopyalandığında:** Hafif onay hissi (`.generic`).
* **Hata / İzin Reddedildiğinde:** Çift vuruş hissi.

---

## 7. Spacing & Izgara Sistemi (8pt Grid)

Tüm boşluklar ve iç kenar payları (padding) 4px ve 8px katı sistemine uyar:
* `xs`: 4px (İkon-metin arası)
* `sm`: 8px (Küçük buton iç boşluğu)
* `md`: 16px (Kartlar arası mesafe, standart panel padding)
* `lg`: 24px (Ana modüller arası ayırıcı)
* `xl`: 32px (Panel dış marjini)
