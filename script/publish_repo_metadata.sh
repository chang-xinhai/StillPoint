#!/usr/bin/env bash
set -euo pipefail

repo="chang-xinhai/StillPoint"
homepage="https://chang-xinhai.github.io/StillPoint/"
description="StillPoint is a macOS menu bar attention guardian that protects the pause before doomscrolling takes over."
gh repo edit "$repo" \
  --visibility public \
  --accept-visibility-change-consequences \
  --description "$description" \
  --homepage "$homepage" \
  --add-topic macos \
  --add-topic swiftui \
  --add-topic menu-bar \
  --add-topic attention \
  --add-topic digital-wellbeing \
  --add-topic productivity \
  --add-topic doomscrolling
