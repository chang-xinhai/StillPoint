# Releasing StillPoint for macOS

StillPoint is a macOS 14+ menu bar app (`LSUIElement=true`) built from SwiftPM
and packaged as a standard `.app` bundle. The local release path intentionally
matches the simple parts of CodexBar's distribution pattern: build a clean app
bundle, sign the assembled bundle, create a versioned zip, optionally create a
drag-to-Applications DMG, and keep notarization as an explicit production step.

## Local package

```bash
./script/package_release.sh
```

The script writes:

- `dist/StillPoint.app`
- `dist/release/StillPoint-macos-<arch>-<version>.zip`
- `dist/release/StillPoint-macos-<arch>-<version>.zip.sha256`
- `dist/release/StillPoint-macos-<arch>-<version>.dmg` when `hdiutil` is present
- `dist/release/StillPoint-macos-<arch>-<version>.dmg.sha256` when a DMG is created

By default, the script uses ad-hoc signing (`codesign --sign -`) so local
signature verification succeeds after the bundle is assembled. This is useful
for testing, but it is not a production trust chain. A zip or DMG downloaded
from the internet will still fail Gatekeeper because it is not signed with a
Developer ID certificate and is not notarized by Apple.

Useful options:

```bash
VERSION=0.1.0 BUILD_NUMBER=12 ./script/package_release.sh
./script/package_release.sh --skip-dmg
./script/package_release.sh --package-existing
./script/package_release.sh --sign "Developer ID Application: Your Name (TEAMID)"
./script/package_release.sh --no-sign
```

## Validate a local artifact

```bash
codesign --verify --strict --verbose=2 dist/StillPoint.app
codesign -dv --verbose=4 dist/StillPoint.app
spctl -a -t exec -vv dist/StillPoint.app
unzip -l dist/release/StillPoint-macos-*-*.zip | head -40
```

For ad-hoc builds, `codesign --verify` should pass and `spctl` is expected to
warn that the app is rejected or lacks an accepted source. Treat that as the
unsigned/local-build warning, not as a packaging failure.

## Production signing and notarization

Production distribution needs:

- An Apple Developer account.
- A `Developer ID Application` certificate installed in the build keychain.
- App Store Connect API key credentials for `xcrun notarytool`.

Minimal production flow:

```bash
./script/package_release.sh --sign "Developer ID Application: Your Name (TEAMID)"
/usr/bin/ditto --norsrc -c -k --keepParent dist/StillPoint.app /tmp/StillPoint-notarize.zip
xcrun notarytool submit /tmp/StillPoint-notarize.zip \
  --key /path/to/AuthKey_KEYID.p8 \
  --key-id KEYID \
  --issuer ISSUER_UUID \
  --wait
xcrun stapler staple dist/StillPoint.app
codesign --verify --strict --verbose=2 dist/StillPoint.app
spctl -a -t exec -vv dist/StillPoint.app
./script/package_release.sh --package-existing
```

The final `--package-existing` run recreates the release zip and DMG from the
same stapled bundle without rebuilding or re-signing it. If you notarize a DMG
separately, submit and staple that DMG too.

## GitHub Release

In this environment, `gh auth status` succeeds but SSH git transport is blocked:
`git push --dry-run origin main` fails with `Connection closed by 198.18.0.19
port 22`. Publishing must wait until GitHub SSH is reachable or the remote is
temporarily switched to HTTPS.

Recovery commands:

```bash
gh auth status
git remote -v
git push origin main
gh release create v0.1.0 \
  dist/release/StillPoint-macos-*-0.1.0.zip \
  dist/release/StillPoint-macos-*-0.1.0.zip.sha256 \
  dist/release/StillPoint-macos-*-0.1.0.dmg \
  dist/release/StillPoint-macos-*-0.1.0.dmg.sha256 \
  --repo chang-xinhai/StillPoint \
  --title "StillPoint 0.1.0" \
  --notes "Unsigned local build unless the attached artifact was Developer ID signed and notarized."
```

For a production release, replace the notes with the signing/notarization status
and attach only artifacts built from the notarized app.

If SSH remains blocked, switch the remote to HTTPS after confirming the intended
repo:

```bash
git remote set-url origin https://github.com/chang-xinhai/StillPoint.git
git push origin main
```
