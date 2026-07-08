#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ASSETS_DIR="$ROOT_DIR/Assets"
ICONSET="$ASSETS_DIR/StillPoint.iconset"
SOURCE_PNG="$ASSETS_DIR/AppIcon-1024.png"
ICNS="$ASSETS_DIR/Icon.icns"

mkdir -p "$ASSETS_DIR"
swift "$ROOT_DIR/script/generate_icon.swift" "$SOURCE_PNG" >/dev/null

rm -rf "$ICONSET"
mkdir -p "$ICONSET"

make_icon() {
  local size="$1"
  local scale="$2"
  local pixels=$((size * scale))
  local suffix=""
  if [[ "$scale" == "2" ]]; then
    suffix="@2x"
  fi
  /usr/bin/sips -z "$pixels" "$pixels" "$SOURCE_PNG" --out "$ICONSET/icon_${size}x${size}${suffix}.png" >/dev/null
}

make_icon 16 1
make_icon 16 2
make_icon 32 1
make_icon 32 2
make_icon 128 1
make_icon 128 2
make_icon 256 1
make_icon 256 2
make_icon 512 1
make_icon 512 2

/usr/bin/iconutil -c icns "$ICONSET" -o "$ICNS"
rm -rf "$ICONSET"

printf '%s\n' "$ICNS"
