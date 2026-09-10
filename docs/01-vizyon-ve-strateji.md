# Çentik – Vizyon ve Strateji Belgesi

**Ürün:** Çentik (Global: *Centik*)  
**Slogan:** *"Çentiğindeki ada."* (Global: *"Your notch, working."*)  
**Felsefe:** *"Gösteren değil, bitiren ada."*  
**Lisans Modeli:** Açık Çekirdek (MIT) + Pro Sürüm  

---

## 1. Ürün Vizyonu

Apple, 2021 yılında MacBook ekranlarına çentiği (notch) eklediğinde donanım için bir zorunluluk sundu ancak bu alanı işlevsel bir yazılım deneyimine dönüştürmedi. iPhone'daki "Dynamic Island" konsepti macOS'e resmi olarak hiç gelmedi.

Pazardaki mevcut çentik uygulamaları ekranın üstünü bir bildirim vitrinine, animasyon tahtasına veya onlarca karmaşık widget ile dolu hantal bir panoya dönüştürdü. 

**Çentik'in Varlık Amacı:**  
Çentik, ekranın en değerli ve atıl noktasını **günlük iş akışını hızlandıran, dikkat dağıtmayan ve masaüstü karmaşasını bitiren hafif bir eylem merkezine** dönüştürür.

> Çentik sadece bilgi göstermez; iş bitirir. Dosyayı tutar, panoyu yönetir, müziği denetler ve toplantıya bağlar.

---

## 2. Temel İlkeler (Core Tenets)

1. **Sıfır Pil Kaybı (0% Idle CPU):**
   Arka planda gereksiz döngüler (polling) asla çalışmaz. Uygulama tamamen sistem olayları (event-driven: bildirimler, pano sayaçları, dosya sistemi olayları) ile tetiklenir. Seam ve NotchNook gibi rakiplerin en büyük şikayet konusu olan pil tüketimi Çentik'te sıfıra indirgenmiştir.

2. **Göster Değil, Bitir:**
   Her ada etkileşimi somut bir aksiyonla sonlanır: Dosyayı sürükleyip bırakmak, panodaki metni yapıştırmak, toplantıya tek tıkla girmek, müziği değiştirmek.

3. **Hafif ve Yerel (Local-First):**
   Çentik bir hesap istemez, üyelik dayatmaz, telemetri toplamaz. Verileriniz (pano geçmişi, raf dosyaları) tamamen cihazınızda kalır. Bellek ayak izi 35 MB'ın altındadır.

4. **Çentiksiz Mac'lerde Kusursuz Hap (Floating Pill):**
   M1 MacBook Air, Mac mini, Mac Studio veya harici monitör kullananlar dışlanmaz. Çentik algılanamadığında zarif bir yüzen hap moduna geçer.

5. **Açık Çekirdek ve Topluluk Güveni:**
   Çekirdek altyapı MIT lisansıyla açıktır. Kullanıcı ve geliştirici topluluğu kodun şeffaflığına, gizliliğine ve güvenliğine tam olarak kefil olabilir.

---

## 3. Hedef Kitle

* **Mac Güç Kullanıcıları (Power Users):** Gün boyu masaüstünde onlarca dosya, ekran görüntüsü ve metinle boğuşanlar.
* **Tasarımcılar & Geliştiriciler:** Görsel ve kod parçacıklarını pencereler arasında hızlıca transfer etmek isteyenler.
* **Uzaktan Çalışan Profesyoneller:** Gün içinde sık sık Zoom/Meet toplantılarına giren, takvim ve medya kontrollerini menü çubuğunu kirletmeden çözmek isteyenler.
* **Minimalistler:** Ekranında Bartender, Dropover, Maccy, MediaMate gibi 4-5 farklı küçük araç yerine tek, hafif ve estetik bir çözüm arayanlar.

---

## 4. İş ve Dağıtım Modeli

Çentik, "ücretsiz açık çekirdek" ile hızla yayılıp "gelişmiş araçlar" ile gelir üreten şeffaf bir modele sahiptir:

### Ücretsiz Çekirdek (Community / MIT)
* Boş ada ve akıcı animasyonlar (Notch & Pill modu)
* Now Playing müzik kontrolleri
* Sistem HUD (Ses, parlaklık, klavye ışığı)
* 30 öğelik yerel pano geçmişi
* 5 slotlu dosya rafı (FileShelf)
* Takvim / toplantı rozeti

### Çentik Pro ($19 Tek Seferlik Ömür Boyu Lisans)
* Sınırsız dosya rafı alanı ve toplu AirDrop transferi
* Sınırsız pano geçmişi ve favori pinleme
* Gelecek modüller: Drop-to-convert (HEIC/PNG/PDF dönüştürücü), offline dikte ve sistem istatistikleri
* Özel temalar ve menü-bar kişiselleştirmeleri

### Dağıtım Kanalları
1. **Homebrew Cask:** `brew install --cask centik` (Geliştirici kitlesine ilk günden zahmetsiz kurulum)
2. **Resmi Web Sitesi:** Notarized & Apple Developer imzalı DMG dağıtımı (centik.app)
3. **GitHub Releases:** Açık kaynak buildler ve sürüm notları
