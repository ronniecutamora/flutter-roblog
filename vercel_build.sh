#!/usr/bin/env bash
# vercel_build.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLUTTER_DIR="$SCRIPT_DIR/flutter"
FLUTTER_BIN="$FLUTTER_DIR/bin/flutter"

if [ ! -d "$FLUTTER_DIR" ]; then
  echo ">>> Cloning Flutter stable..."
  git clone https://github.com/flutter/flutter.git -b stable "$FLUTTER_DIR"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

echo ">>> Using flutter: $(command -v "$FLUTTER_BIN" || command -v flutter || true)"
"$FLUTTER_BIN" --version

# Ensure stable channel
"$FLUTTER_BIN" channel stable
"$FLUTTER_BIN" upgrade --force

# Enable web artifacts
"$FLUTTER_BIN" config --enable-web
"$FLUTTER_BIN" precache --web

# Get packages
"$FLUTTER_BIN" pub get

# BUILD SECTION
# We inject Vercel Env Vars directly into the build command using --dart-define
# This prevents the .env file from being publicly accessible in the assets folder.

: "${PWA_STRATEGY:=none}"
: "${USE_WASM:=false}"

# Define the common flags to avoid repetition
DEFINES="--dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY"

if [ "$USE_WASM" = "true" ]; then
  echo ">>> Building web (wasm mode)"
  "$FLUTTER_BIN" build web --release --pwa-strategy="$PWA_STRATEGY" --wasm $DEFINES
else
  echo ">>> Building web (default renderer)"
  "$FLUTTER_BIN" build web --release --pwa-strategy="$PWA_STRATEGY" $DEFINES
fi

echo "Flutter web build finished. Output: build/web"
