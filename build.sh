#!/bin/bash
# Build ZipDrop.ipa tren macOS (khong can Xcode project)
set -euo pipefail
cd "$(dirname "$0")"

APP=ZipDrop
OUT=build
BUNDLE="$OUT/Payload/$APP.app"

command -v xcrun >/dev/null || { echo "!! thieu Xcode"; exit 1; }
SDK=$(xcrun --sdk iphoneos --show-sdk-path)

rm -rf "$OUT"
mkdir -p "$BUNDLE"

xcrun -sdk iphoneos swiftc \
    -target arm64-apple-ios15.0 \
    -sdk "$SDK" \
    -O -parse-as-library -emit-executable \
    -module-name "$APP" \
    -framework SwiftUI -framework UIKit \
    -o "$BUNDLE/$APP" \
    ZipDrop.swift

cp Info.plist "$BUNDLE/Info.plist"
printf 'APPL????' > "$BUNDLE/PkgInfo"

if command -v ldid >/dev/null; then ldid -S "$BUNDLE/$APP" || true; fi

( cd "$OUT" && zip -qr "$APP.ipa" Payload )
echo "XONG: $OUT/$APP.ipa"
