#!/bin/zsh
# Centik.app paketler: sürüm git tag'inden gelir (v öneki atılır).
#   git tag v0.2 && git push origin v0.2  →  sürüm 0.2, build = kısa hash
# İmza: CODESIGN_IDENTITY boşsa ad-hoc imzalanır (dağıtılmaz, yerel test).
# Sparkle anahtarı: SPARKLE_PUBLIC_KEY env'den yazılır, yoksa yer tutucu kalır.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

TAG="$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")"
VERSION="${TAG#v}"
BUILD="$(git rev-parse --short HEAD)"
KEY="${SPARKLE_PUBLIC_KEY:-EDKEY_BURAYA}"
IDENTITY="${CODESIGN_IDENTITY:-}"

echo "==> Sürüm $VERSION (build $BUILD)"

swift build -c release

APP="$ROOT/dist/Centik.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

cp ".build/release/Centik" "$APP/Contents/MacOS/Centik"
sed -e "s/@APP_VERSION@/$VERSION/" \
    -e "s/@BUILD_NUMBER@/$BUILD/" \
    -e "s/@SPARKLE_PUBLIC_KEY@/$KEY/" \
    "$ROOT/packaging/Info.plist" > "$APP/Contents/Info.plist"
printf 'APPL????' > "$APP/Contents/PkgInfo"

if [[ -n "$IDENTITY" ]]; then
    echo "==> İmzalanıyor ($IDENTITY)"
    codesign --force --options runtime --sign "$IDENTITY" "$APP"
else
    echo "==> Ad-hoc imza (yerel test)"
    codesign --force --sign - "$APP"
fi

ZIP="$ROOT/dist/Centik-$VERSION.zip"
rm -f "$ZIP"
ditto -c -k --keepParent "$APP" "$ZIP"
echo "==> Hazır: $ZIP"
