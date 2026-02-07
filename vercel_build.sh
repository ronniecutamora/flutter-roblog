#!/usr/bin/env bash
set -euo pipefail

if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable flutter
fi

export PATH="$PWD/flutter/bin:$PATH"

flutter config --enable-web
flutter precache --web

flutter pub get

: "${WEB_RENDERER:=canvaskit}"
: "${PWA_STRATEGY:=none}"

flutter build web --release --pwa-strategy="$PWA_STRATEGY" --web-renderer="$WEB_RENDERER"

echo "Flutter web build finished. Output: build/web"
