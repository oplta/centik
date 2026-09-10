# Çentik – Güncelleme Altyapısı (Sparkle + Git Tag)

Kullanıcı yeni sürümü elle kurmaz. Akış:

```
git tag v0.3 && git push origin v0.3
  → CI derler → imzalar → noterize eder → GitHub Release'e zip atar
  → appcast.xml güncellenir
  → kullanıcı uygulamayı açınca Sparkle sessizce indirir, kurar, yeniden başlatır
```

Homebrew kullanıcıları bu akışın dışındadır: Caskroom altından çalışan
uygulamada Sparkle başlatılmaz, `brew upgrade` yönetir (`Core/Updater/UpdateManager.swift`).

## Sürüm kuralı

- v-numaraları **semboliktir** (faz adı). Gerçek sürüm = **git tag + commit hash**.
- `scripts/package-app.sh` tag'den `CFBundleShortVersionString`, hash'ten
  `CFBundleVersion` üretir. Kodda sürüm sabiti yoktur.

## Sana kalan 4 iş (bensiz yapılamaz)

1. **Sparkle anahtarı:** Sparkle `generate_keys` aracını çalıştır, public key'i
   `SPARKLE_PUBLIC_KEY` secret'ına ve ilk pakette Info.plist'e yaz.
   Private key yalnızca sende + GitHub secret'ta durur.
2. **Apple secret'ları:** `APPLE_CERT_P12`, `APPLE_CERT_PASSWORD`, `APPLE_ID`,
   `APPLE_TEAM_ID`, `APPLE_APP_PASSWORD`, `CODESIGN_IDENTITY`
   (Developer ID Application). Bunlar yokken CI ad-hoc imzalar, dağıtılmaz.
3. **Appcast hosting:** repo Settings → Pages'i aç (docs/ klasöründen veya
   gh-pages). `SUFeedURL` = `https://oplta.github.io/centik/appcast.xml`.
   Her release'te Sparkle `generate_appcast` ile feed'i üretip yayınla.
4. **İlk kesim:** yukarıdakiler bitince `git tag v0.1 && git push origin v0.1`.

## Dosyalar

- `Core/Updater/UpdateManager.swift` — Sparkle sarmalayıcı + Caskroom koruması.
- `packaging/Info.plist` — şablon (`@APP_VERSION@`, `@SPARKLE_PUBLIC_KEY@`).
- `scripts/package-app.sh` — derle → .app → imzala → zip.
- `.github/workflows/release.yml` — tag'de CI (secret yoksa güvenli pas geçer).
