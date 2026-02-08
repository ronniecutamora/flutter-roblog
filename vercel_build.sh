#!/usr/bin/env bash
# vercel_build.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLUTTER_DIR="$SCRIPT_DIR/flutter"
FLUTTER_BIN="$FLUTTER_DIR/bin/flutter"

if [ ! -d "$FLUTTER_DIR" ]; then
  git clone https://github.com/flutter/flutter.git -b stable "$FLUTTER_DIR"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

echo ">>> Using flutter: $(command -v "$FLUTTER_BIN" || command -v flutter || true)"
"$FLUTTER_BIN" --version
"$FLUTTER_BIN" doctor -v || true
"$FLUTTER_BIN" build web -h || true

# ensure stable channel & toolchain completeness
"$FLUTTER_BIN" channel stable
"$FLUTTER_BIN" upgrade --force

# enable web artifacts
"$FLUTTER_BIN" config --enable-web
"$FLUTTER_BIN" precache --web

# NEW: Create the .env file that pubspec.yaml is looking for
echo ">>> Creating .env file from Vercel Environment Variables"
cat <<EOF > .env
SUPABASE_URL=$SUPABASE_URL
SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
EOF

# Verify it exists so the build doesn't fail
ls -la .env

# get packages
"$FLUTTER_BIN" pub get

# build: note we NO LONGER pass --web-renderer
: "${PWA_STRATEGY:=none}"
: "${USE_WASM:=false}"  # set USE_WASM=true in Vercel env to compile to WebAssembly

if [ "$USE_WASM" = "true" ]; then
  echo ">>> Building web (wasm mode) pwa_strategy='$PWA_STRATEGY'"
  "$FLUTTER_BIN" build web --release --pwa-strategy="$PWA_STRATEGY" --wasm
else
  echo ">>> Building web (default renderer selection) pwa_strategy='$PWA_STRATEGY'"
  "$FLUTTER_BIN" build web --release --pwa-strategy="$PWA_STRATEGY"
fi

echo "Flutter web build finished. Output: build/web"
