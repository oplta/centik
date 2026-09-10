# Çentik – Marka ve Tasarım Rehberi

Bu belge, Çentik'in kurumsal kimliğini, görsel tasarım sistemini, renk paletini, tipografisini ve iletişim dilini belirler.

---

## 1. Marka İsmi ve Hikayesi

* **Türkçe:** Çentik  
* **Global / CLI / Homebrew:** Centik (`brew install --cask centik`)  
* **Bundle ID:** `app.centik.mac`  

### Hikaye
Apple, MacBook'lara çentiği yerleştirdi ancak bu alan yıllarca siyah bir boşluk olarak kaldı. Çentik, bu atıl donanım alanını masaüstünün en işlevsel eylem merkezine dönüştürür. Çentik ismi, hem donanımsal çentiğin öz Türkçe karşılığıdır hem de "işaret koymak / tamamlamak" anlamındaki kültürel çağrışımı taşır.

---

## 2. Sloganlar ve İletişim Tonu

### Sloganlar
* **Ana Slogan (TR):** *"Çentiğindeki ada."*
* **Ana Slogan (EN):** *"Your notch, working."*
* **Eylem Sloganı:** *"Bırak. Dursun. Geri al."*
* **Alt Başlık:** *"MacBook çentiğin sonunda işe yarıyor."*

### Ses Tonu (Tone of Voice)
* **Sakin ve Kendinden Emin:** Abartılı pazarlama klişelerinden ve "yapay zeka devrimi" gibi içi boş iddialardan uzak.
* **Ölçülebilir ve Dürüst:** "Pili tüketmez" demek yerine "Idle %0 CPU, 35MB RAM, sıfır arka plan döngüsü" gibi somut veri konuşur.
* **Kısa ve Net Cümleler:** Emir kipleri ve net ifadeler: *"Hesap yok. Bulut yok. Veriniz yalnızca cihazınızda."*

---

## 3. Renk Paleti (Siyah & Elektrik Mavisi)

Çentik'in resmi renk sistemi; derin obsidiyen/OLED siyahı ile saf elektrik mavisinin (`#0066FF`) yüksek kontrastlı, fütüristik ve modern uyumuna dayanır:

| Renk Adı | Hex Kodu | Kullanım Alanı | Anlamı / Hissi |
| :--- | :--- | :--- | :--- |
| **Obsidiyen Siyah** | `#07090E` | Ana uygulama ve ada gövdesi, karanlık zemin | Ekran donanım çentiğiyle birebir kaynaşma |
| **Gece Laciverti** | `#091428` | Dış dalga katmanları, panel zemin ayrımı | Derinlik ve arka plan geçişi |
| **Karanlık Safir** | `#071C44` | Panel gölgeleri, ikincil konturlar | Asil gece tonu |
| **Derin Kobalt** | `#00256B` | Seçili olmayan eylemler, alt katmanlar | Güç ve stabilite |
| **Kraliyet Mavisi** | `#003494` | Hover durumları, kart kenarlıkları | Premium his |
| **Elektrik Mavisi** | `#0066FF` | **Birincil Marka Rengi**, aktif aksiyonlar, butonlar | Net odak, canlılık ve enerji |
| **Açık Gökyüzü** | `#008AFF` | İkincil aksiyonlar, dalga geçişleri | Akıcılık |
| **Canlı Cam Göbeği**| `#00B4FF` | Müzik dalgası (waveform), medya akışı | Dinamik hareket |
| **Buz Mavisi / Çekirdek**| `#E0F2FE` | Çentik çekirdek aydınlatması, tepe parıltısı | Lüks cam parıltısı ve kontrast |
| **Panel Çerçevesi** | `#1E293B` | 1.5px ince panel kenarlığı, ayırıcılar | Keskin mimari hatlar |
| **Uyarı Kehribar** | `#FF9F0A` | Sistem izin uyarıları, pil uyarısı | Standart Apple dikkati |

> **Tasarım Kuralı:** Zemin daima obsidiyen siyahıdır (`#07090E`). Elektrik Mavisi (`#0066FF`) kullanıcının etkileşime gireceği tek birincil eyleme rehberlik eder; gereksiz renk karmaşasından kaçınılır.

---

## 4. Logo ve İkonografi

Uygulamanın resmi kurumsal logosu; **katsayısal (1.2x geometrik çarpanlı) basamaklı çentik dalgası (Geometric Multiplier Stepped Notch)** mimarisine dayanır:

### Ana Logo: Basamaklı Çentik (`assets/centik-logo.svg`)
* **Konum & Çentik Formu:** Tıpkı MacBook donanım çentiği gibi doğrudan ekranın en üst kenarından (`y = 0`) başlar ve gerçek donanım çentiği omuz kavislerini (*notch shoulders*) taşır.
* **Katsayısal Dalga Dinamiği (1.2x):** 9 kademe, merkezde ince ve odaklanmış başlar (`22px`), dışa doğru **~1.2x katlanarak** bir ses/su dalgası gibi açılarak genişler. Kademeler arası 8 geçiş aralığı: (`22px → 27px → 34px → 42px → 52px → 64px → 78px → 96px`).
* **Alt Çizgi & Geometri:** Her kademenin tabanı dümdüz yatay bir çentik çizgisi ve yumuşak köşe kavisleridir.
* **Renk Basamakları:** Derin gece lacivertinden (`#091428`), kraliyet mavisinden (`#003494`), canlı elektrik mavisinden (`#0066FF`), cam göbeğinden (`#00B4FF`) en içteki açık buz mavisine (`#E0F2FE`) kadar 9 kademeli organik geçiş.
* **Sadelik:** Sıfır gölge, sıfır kamera noktası veya yabancı süs; tamamen saf, dinamik çentik dalgası.

Önizleme için: `docs/preview.html`

---

## 5. Tipografi

* **Uygulama İçi (macOS Native):** **SF Pro** (Apple Sistem Fontu).
  * Başlıklar: SF Pro Rounded / Bold
  * Gövde: SF Pro Text / Regular
  * Sayaçlar & Kısayollar: SF Pro Display / Monospaced
* **Web Sitesi & Tanıtım:**
  * **Başlıklar:** *Space Grotesk* (Google Fonts, OFL)
  * **Metinler:** *Inter* (Google Fonts, OFL)

---

## 6. Landing Sayfası Taslağı (centik.app)

* **Hero Bölümü:**
  * Üst Başlık: *Açık Çekirdekli macOS Yardımcısı*
  * Büyük Başlık: *MacBook çentiğin sonunda işe yarıyor.*
  * Açıklama: *Müzik denetimi, 30 öğelik pano, hızlı dosya rafı ve toplantı bildirimleri. Ekranınızın atıl alanını sıfır pil tüketimiyle en güçlü iş merkezinize dönüştürün.*
  * Aksiyon: `[Ücretsiz İndir (v1.0 DMG)]` & `[brew install --cask centik]`
* **3 Temel Değer Kartı:**
  1. *Bırak, Dursun (Dosya Rafı):* Dosyaları çentiğe sürükleyin; pencereler arasında kaybolmadan istediğiniz yere bırakın.
  2. *Kopyala, Bul (Mini Pano):* Son 30 kopyalamanız parmaklarınızın ucunda. Şifrelerinizi kaydetmez, belleği yormaz.
  3. *Bakmadan Bil (Medya & Toplantı):* Çalan şarkıyı görün, tek tıkla Zoom'a girin, ses ayarını ekranı kaplamadan yapın.
* **Şeffaflık Bölümü:**
  * *Idle CPU: %0.0*
  * *RAM: < 35 MB*
  * *Telemetri: Sıfır. Hesap yok. Bulut yok.*
