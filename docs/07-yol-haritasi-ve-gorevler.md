# Çentik – Görev Planı (v2'ye kadar)

## Sürüm ilkesi

- **v-numaraları semboliktir** (faz adı, pazarlama dili). Gerçek sürüm takibi
  **git**'tedir: annotated tag (`v0.1`, `v0.2`…) + commit hash.
- Kural: her faz kapanışında tag atılır (`git tag -a v0.X -m "..."`).
- Uygulama sürüm numarası kodda yazmaz; `scripts/package-app.sh` tag + hash'ten üretir.
- Dağıtım: tag → CI → GitHub Release → Sparkle/appcast (docs/08) veya `brew upgrade`.

## Durum anahtarı

`[x]` bitti · `[~]` kısmen · `[ ]` duruyor. Kanıt = commit hash'i.

## v0.1 — Ada iskeleti `[x]` (tag: v0.1)

- [x] `NotchPanel` (non-activating, screenSaver, allSpaces) + passthrough hit-test
- [x] `ScreenManager` (auxiliary-alan çentik tespiti + hap fallback)
- [x] `NotchContainerView` (cam gövde, spring fizik, hover 0.18s/0.35s)
- [x] `IslandTheme` protokolü + ObsidianTheme + ThemeManager
- [x] Global kısayollar ⌥Space/⌥V (Carbon, izinsiz)
- [x] Başlıkta quit düğmesi; ölü Esc kodu silindi
- [x] a11y: gerçek Button'lar, label/hint, reduce motion/transparency
- [x] Sparkle altyapısı (kod + paketleme + CI; secret'lar kullanıcıda — docs/08)

## v0.2 — Raf gerçekten kullanışlı `[ ]`

- [x] **DragMonitor** (`Core/DragMonitor`): global fare + drag-pasteboard ile sürükleme bölgeye girince aç/çıkınca kapat. Kabul: Finder'dan sürüklerken ada hedef büyümeden önce açılır. Not: Erişilebilirlik izni ister → ilk açılışta sistem penceresi çıkar.
- [ ] **Çok tipli drop**: dosya + link + metin merdiveni (Boring ShelfDropService sırası). Kabul: link/metin de rafta durur.
- [x] **Raf ızgarası**: thumbnail kartlar (QLThumbnail), pin rozeti, sağ-tık (Aç/Finder'da Göster/Kaldır). Kabul: 5 dosya görsel kart olarak durur.
- [ ] **Raftan dışarı sürükleme** + QuickLook (Boşluk). Kabul: raftan Finder'a dosya taşınır.
- [x] Kalıcılık (bookmark kaydet/yükle/temizle) — v0.1'de yazıldı.
- [ ] Kapanış: `git tag v0.2`.

## v0.3 — Medya gerçek kontrol `[~]` (bilgi var, kontrol yok)

- [x] Sistem geneli parça/sanatçı/kapak (MediaRemote dlopen).
- [ ] **Transport**: `MRMediaRemoteSendCommand` (oynat/duraklat/sonraki/önceki/±15sn). Kabul: YouTube dahil her kaynak kontrol edilir, izin prompt'u yok.
- [ ] İlerleme çubuğu + seek (yalnızca açık + çalarken tick).
- [ ] Uygulama rozeti (hangi uygulamadan çaldığı).
- [ ] Kapanış: `git tag v0.3`.

## v0.4 — v1 kapanış `[ ]`

- [ ] Mini Pano 30 + `⌥V` odağı (ConcealedType filtresi; OCR yok).
- [ ] Sistem HUD (ses/parlaklık/klavye ışığı).
- [ ] Takvim çipi (tek-tık katılım; çağrı kontrolü yok).
- [ ] Kapanış: `git tag v1.0` + Homebrew cask PR + r/macapps beta.

## v2 — Pro `[ ]`

- [ ] Drop-to-convert (HEIC→JPG/PNG, sıkıştırma, PDF birleştirme).
- [ ] Offline dikte (basılı-tut konuş).
- [ ] Pano OCR (Vision, on-device).
- [ ] Mini sistem monitörü (istemli, poll yok).
- [ ] Pro lisanslama ($19 lifetime) + Setapp başvurusu.
