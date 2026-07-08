#!/usr/bin/env bash
set -euo pipefail

APP_NAME="StillPoint"
BUNDLE_ID="com.changxinhai.StillPoint"
MIN_SYSTEM_VERSION="14.0"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
RELEASE_DIR="$DIST_DIR/release"
APP_BUNDLE="$DIST_DIR/$APP_NAME.app"
APP_CONTENTS="$APP_BUNDLE/Contents"
APP_MACOS="$APP_CONTENTS/MacOS"
APP_RESOURCES="$APP_CONTENTS/Resources"
APP_BINARY="$APP_MACOS/$APP_NAME"
INFO_PLIST="$APP_CONTENTS/Info.plist"
ICON_FILE="$ROOT_DIR/Assets/Icon.icns"

CREATE_DMG=1
PACKAGE_EXISTING=0
SIGN_IDENTITY="${SIGN_IDENTITY:--}"
VERSION="${VERSION:-}"
BUILD_NUMBER="${BUILD_NUMBER:-}"

usage() {
  cat <<EOF
usage: $0 [--skip-dmg] [--package-existing] [--sign IDENTITY] [--no-sign] [--version VERSION] [--build BUILD]

Build a clean StillPoint.app release bundle and package it as a zip. A DMG is
also created when hdiutil is available unless --skip-dmg is passed.

Use --package-existing after notarization/stapling to recreate artifacts from
the current dist/StillPoint.app without rebuilding or re-signing it.

Environment:
  SIGN_IDENTITY   codesign identity; defaults to "-" for ad-hoc local signing
  VERSION         marketing version; defaults to latest git tag or 0.1.0
  BUILD_NUMBER    build number; defaults to git commit count
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip-dmg)
      CREATE_DMG=0
      shift
      ;;
    --package-existing)
      PACKAGE_EXISTING=1
      shift
      ;;
    --sign)
      SIGN_IDENTITY="${2:?missing signing identity}"
      shift 2
      ;;
    --no-sign)
      SIGN_IDENTITY=""
      shift
      ;;
    --version)
      VERSION="${2:?missing version}"
      shift 2
      ;;
    --build)
      BUILD_NUMBER="${2:?missing build number}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

cd "$ROOT_DIR"

if [[ -z "$VERSION" ]]; then
  VERSION="$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//' || true)"
  VERSION="${VERSION:-0.1.0}"
fi

if [[ -z "$BUILD_NUMBER" ]]; then
  BUILD_NUMBER="$(git rev-list --count HEAD 2>/dev/null || true)"
  BUILD_NUMBER="${BUILD_NUMBER:-1}"
fi

case "$(uname -m)" in
  arm64) ARCH_LABEL="macos-arm64" ;;
  x86_64) ARCH_LABEL="macos-x86_64" ;;
  *) ARCH_LABEL="macos-$(uname -m)" ;;
esac

ZIP_PATH="$RELEASE_DIR/$APP_NAME-$ARCH_LABEL-$VERSION.zip"
DMG_PATH="$RELEASE_DIR/$APP_NAME-$ARCH_LABEL-$VERSION.dmg"

if [[ "$PACKAGE_EXISTING" == "0" ]]; then
  if pgrep -x "$APP_NAME" >/dev/null 2>&1; then
    echo "Stopping running $APP_NAME before replacing $APP_BUNDLE"
    pkill -x "$APP_NAME" >/dev/null 2>&1 || true
  fi

  echo "Building $APP_NAME $VERSION ($BUILD_NUMBER) for Release"
  swift build -c release
  BUILD_BINARY="$(swift build -c release --show-bin-path)/$APP_NAME"

  rm -rf "$APP_BUNDLE" "$RELEASE_DIR"
  mkdir -p "$APP_MACOS" "$APP_RESOURCES" "$RELEASE_DIR"
  cp "$BUILD_BINARY" "$APP_BINARY"
  chmod +x "$APP_BINARY"

  if [[ -f "$ICON_FILE" ]]; then
    cp "$ICON_FILE" "$APP_RESOURCES/Icon.icns"
  else
    echo "WARN: missing icon at $ICON_FILE" >&2
  fi

  cat >"$INFO_PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleDisplayName</key>
  <string>$APP_NAME</string>
  <key>CFBundleExecutable</key>
  <string>$APP_NAME</string>
  <key>CFBundleIdentifier</key>
  <string>$BUNDLE_ID</string>
  <key>CFBundleIconFile</key>
  <string>Icon</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>$APP_NAME</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>$VERSION</string>
  <key>CFBundleVersion</key>
  <string>$BUILD_NUMBER</string>
  <key>LSApplicationCategoryType</key>
  <string>public.app-category.productivity</string>
  <key>LSMinimumSystemVersion</key>
  <string>$MIN_SYSTEM_VERSION</string>
  <key>LSUIElement</key>
  <true/>
  <key>NSPrincipalClass</key>
  <string>NSApplication</string>
</dict>
</plist>
PLIST

  printf "APPL????" > "$APP_CONTENTS/PkgInfo"
  xattr -cr "$APP_BUNDLE"
  find "$APP_BUNDLE" -name '._*' -delete

  if [[ -n "$SIGN_IDENTITY" ]]; then
    if [[ "$SIGN_IDENTITY" == "-" ]]; then
      echo "Ad-hoc signing $APP_BUNDLE for local validation"
      codesign --force --sign - --timestamp=none "$APP_BUNDLE"
      echo "WARN: ad-hoc signed builds are not notarized and will not pass Gatekeeper after download."
    else
      echo "Signing $APP_BUNDLE with $SIGN_IDENTITY"
      codesign --force --timestamp --options runtime --sign "$SIGN_IDENTITY" "$APP_BUNDLE"
    fi
  else
    echo "WARN: leaving $APP_BUNDLE unsigned because --no-sign was passed."
  fi
else
  if [[ ! -d "$APP_BUNDLE" ]]; then
    echo "ERROR: --package-existing requires $APP_BUNDLE" >&2
    exit 1
  fi
  rm -rf "$RELEASE_DIR"
  mkdir -p "$RELEASE_DIR"
  xattr -cr "$APP_BUNDLE"
  find "$APP_BUNDLE" -name '._*' -delete
fi

echo "Verifying bundle signature"
codesign --verify --strict --verbose=2 "$APP_BUNDLE"

if command -v spctl >/dev/null 2>&1; then
  if ! SPCTL_OUTPUT="$(spctl -a -t exec -vv "$APP_BUNDLE" 2>&1)"; then
    echo "WARN: Gatekeeper assessment did not accept this local build:"
    echo "$SPCTL_OUTPUT"
  else
    echo "$SPCTL_OUTPUT"
  fi
fi

echo "Creating zip: $ZIP_PATH"
/usr/bin/ditto --norsrc -c -k --keepParent "$APP_BUNDLE" "$ZIP_PATH"
shasum -a 256 "$ZIP_PATH" > "$ZIP_PATH.sha256"

if [[ "$CREATE_DMG" == "1" ]]; then
  if command -v hdiutil >/dev/null 2>&1; then
    DMG_STAGE="$(mktemp -d "${TMPDIR:-/tmp}/stillpoint-dmg.XXXXXX")"
    trap 'rm -rf "$DMG_STAGE"' EXIT
    cp -R "$APP_BUNDLE" "$DMG_STAGE/"
    ln -s /Applications "$DMG_STAGE/Applications"
    echo "Creating DMG: $DMG_PATH"
    hdiutil create -volname "$APP_NAME" -srcfolder "$DMG_STAGE" -ov -format UDZO "$DMG_PATH"
    shasum -a 256 "$DMG_PATH" > "$DMG_PATH.sha256"
  else
    echo "WARN: hdiutil not found; skipped DMG creation."
  fi
fi

echo "Release artifacts:"
ls -lh "$RELEASE_DIR"
