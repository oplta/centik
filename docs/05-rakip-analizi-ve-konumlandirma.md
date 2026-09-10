# Çentik – Rakip Analizi ve Pazar Konumlandırması

Bu belge, macOS çentik ve dinamik ada ekosistemindeki 10 ana rakibin detaylı analizini ve Çentik'in pazardaki konumlanma stratejisini içerir.

---

## 1. Pazar Genel Bakışı ve Rakip Karşılaştırma Matrisi

| Uygulama | Fiyat Modeli | Kaynak Kodu | Pil & Sistem Yükü | Güçlü Yönü | Temel Zayıflığı |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Notchy** | %100 Ücretsiz | Kapalı | Düşük-Orta (%0-1 CPU) | 71+ özellik, 134 dil, her şeyi tek yerde toplama | Şişkin (bloatware), kapalı kaynak, tek geliştirici riski |
| **Boring Notch** | Ücretsiz (GPL-3.0) | Açık (10k★) | Orta (%1-3 CPU) | Özelleştirilebilirlik, müzik ve raf | İmzasız (Gatekeeper uyarıları), bildirim yok, dağınık kod |
| **NotchNook** | $25 tek / $3 ay | Kapalı | **Kötü (%8-12 idle)** | Raf ve AirDrop olgunluğu, Shortcuts entegrasyonu | Ağır pil tüketimi, yüksek fiyat, pano geçmişi yok |
| **Alcove** | ~$15 tek | Kapalı | Düşük (%0-0.5 CPU) | Akıcı animasyonlar, minimal tasarım | Sadece bildirim ve mini widget; raf veya pano yok |
| **MediaMate** | €6.99 tek | Kapalı | Çok Düşük (%0 CPU) | HUD ve müzik denetiminde sade ve uygun fiyat | Ada değil, sadece HUD aracı; raf/pano yok |
| **DynamicLake**| ~$15 tek | Kapalı | Orta | 8 farklı Dyna modülü ile geniş araç seti | 8 modüllü kurulum son derece karmaşık ve kalabalık |
| **NotchBay** | $9 tek | Kapalı | Düşük | Zoom/Meet toplantı kontrolleri, OCR pano | Sadece macOS 26+, 60 pano limiti, kapalı kaynak |
| **Droppy** | $9.99 tek | Kapalı | Düşük | Dosya rafı + 35 Droplet eklentisi | Marka bilinirliği düşük, karmaşık eklenti yapısı |
| **Seam** | $19.90 tek | Kapalı | Çok Düşük (Event) | Pil odaklı event-driven yapı, yerel dikte | Yüksek fiyat, widget ve görsel derinliği az |
| **Çentik** | **Açık Çekirdek + $19 Pro** | **Açık (MIT)** | **Sıfır (%0 idle)** | **Hafif dosya rafı + pano + HUD + yerel güvenlik** | **Yeni marka (Topluluk ve açık kaynakla aşılacak)** |

---

## 2. Rakiplerin Başarısız Olduğu 3 Kritik Alan

1. **Pil Yönetimi ve CPU Tüketimi (Battery Drain):**
   Birçok kullanıcı NotchNook veya benzeri uygulamaları kurduktan sonra MacBook pil ömrünün 10 saatten 6-7 saate düştüğünü bildirmiştir. Bunun nedeni, arka planda müzik, ses ve fare durumunu sürekli döngülerle (`Timer`) kontrol etmeleridir.  
   *Çentik Çözümü:* Sıfır döngü; tamamen işletim sistemi olayları (`DistributedNotification`, `NSPasteboard.changeCount`, `FSEvents`) ile uyanan event-driven çekirdek.

2. **Aşırı Şişkinlik vs. İşlevsiz Süs:**
   Pazar iki uca bölünmüştür: Bir yanda Notchy gibi 70+ özellik ekleyerek terminalden borsa takibine kadar her şeyi dolduran şişkin uygulamalar; diğer yanda Alcove gibi yalnızca albüm kapağı gösterip hiçbir iş bitirmeyen süs uygulamaları.  
   *Çentik Çözümü:* "Gösteren değil, bitiren ada". Yalnızca günlük iş akışında en çok tekrarlanan 6 işleme odaklanma (Dosyayı tut, panoyu yapıştır, toplantıya gir, sesi ayarla).

3. **Güvenlik ve İmzalanma (Gatekeeper Güveni):**
   Açık kaynak lideri Boring Notch, Apple Developer sertifikası ile imzalanmadığı için macOS Gatekeeper engeline takılmakta ve güvenlik endişesi yaratmaktadır.  
   *Çentik Çözümü:* Apple Developer ID ile imzalanmış, Notarized edilmiş ve Homebrew Cask üzerinden tek komutla doğrulanarak kurulabilen şeffaf yapı.

---

## 3. Çentik'in Rekabet Stratejisi

```
             [ Yüksek Özellik / Şişkin ]
                         |
                         |   * Notchy (71 özellik, kapalı)
                         |
                         |         * DynamicLake
  [ Kapalı / Ücretli ] --+----------------------------- [ Açık Kaynak / Şeffaf ]
                         |
      * NotchNook ($25)  |              * ÇENTİK (Hafif, Raf + Pano, %0 Pil)
      * Alcove ($15)     |
      * MediaMate (€7)   |       * Boring Notch (GPL, 10k★, imzasız)
                         |
             [ Odaklı / Minimal / Hafif ]
```

* **Açık Çekirdek (Open Core) Kozu:** Çekirdeğin açık olması GitHub'da hızla yıldız toplamasını ve yazılımcı topluluğunun güvenini kazanmasını sağlar.
* **Türkçe-First Stratejisi:** Türkiye pazarında güçlü bir kullanıcı ve geri bildirim kitlesi oluşturulup Twitter/X, Reddit r/macapps ve Product Hunt ile küresele açılma.
