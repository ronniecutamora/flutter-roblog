#!/usr/bin/env bash
# vercel_build.sh
set -euo pipefail

# Resolve script dir (so script works no matter where Vercel runs it from)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLUTTER_DIR="$SCRIPT_DIR/flutter"
FLUTTER_BIN="$FLUTTER_DIR/bin/flutter"

# 1) Clone flutter if not present
if [ ! -d "$FLUTTER_DIR" ]; then
  git clone https://github.com/flutter/flutter.git -b stable "$FLUTTER_DIR"
fi

# 2) ensure the binary is used explicitly (avoid PATH issues)
export PATH="$FLUTTER_DIR/bin:$PATH"

# 3) Debug info (helps diagnose which flutter is being used)
echo ">>> Script dir: $SCRIPT_DIR"
echo ">>> Using flutter: $(command -v "$FLUTTER_BIN" || command -v flutter || true)"
"$FLUTTER_BIN" --version
"$FLUTTER_BIN" doctor -v || true
"$FLUTTER_BIN" build web -h || true

# 4) Make sure channel is stable and upgrade (gets latest stable toolchain / flags)
"$FLUTTER_BIN" channel stable
"$FLUTTER_BIN" upgrade --force

# 5) Enable web and precache explicitly using the same binary
"$FLUTTER_BIN" config --enable-web
"$FLUTTER_BIN" precache --web

# 6) Get packages
"$FLUTTER_BIN" pub get

# 7) Build (allow environment override for renderer/strategy)
: "${WEB_RENDERER:=canvaskit}"
: "${PWA_STRATEGY:=none}"

echo ">>> Building web with renderer='$WEB_RENDERER' pwa_strategy='$PWA_STRATEGY'"
"$FLUTTER_BIN" build web --release --pwa-strategy="$PWA_STRATEGY" --web-renderer="$WEB_RENDERER"

echo "Flutter web build finished. Output: build/web"
