#!/usr/bin/env bash
set -euo pipefail
FLUTTER_VERSION="3.24.0"
ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$HOME/Android/Sdk}"
FLUTTER_ROOT="${FLUTTER_ROOT:-$HOME/flutter}"
CMDLINE_TOOLS_ZIP="commandlinetools-linux-11076708_latest.zip"
CMDLINE_TOOLS_URL="https://dl.google.com/android/repository/${CMDLINE_TOOLS_ZIP}"
need_cmd(){ command -v "$1" >/dev/null 2>&1 || { echo "❌ Missing command: $1"; exit 1; }; }
for c in curl unzip xz tar git java; do need_cmd "$c"; done
if [ ! -x "$FLUTTER_ROOT/bin/flutter" ]; then
  tmpdir="$(mktemp -d)"; pushd "$tmpdir" >/dev/null
  curl -fLO "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
  mkdir -p "$(dirname "$FLUTTER_ROOT")"; tar -xJf "flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" -C "$(dirname "$FLUTTER_ROOT")"
  if [ "$(dirname "$FLUTTER_ROOT")/flutter" != "$FLUTTER_ROOT" ]; then mv "$(dirname "$FLUTTER_ROOT")/flutter" "$FLUTTER_ROOT"; fi
  popd >/dev/null; rm -rf "$tmpdir"
fi
export PATH="$FLUTTER_ROOT/bin:$PATH"
mkdir -p "$ANDROID_SDK_ROOT/cmdline-tools"
if [ ! -d "$ANDROID_SDK_ROOT/cmdline-tools/latest" ]; then
  tmpdir="$(mktemp -d)"; pushd "$tmpdir" >/dev/null
  curl -fLO "$CMDLINE_TOOLS_URL"; unzip -q "$CMDLINE_TOOLS_ZIP"
  mkdir -p "$ANDROID_SDK_ROOT/cmdline-tools/latest"; mv cmdline-tools/* "$ANDROID_SDK_ROOT/cmdline-tools/latest/"
  popd >/dev/null; rm -rf "$tmpdir"
fi
export ANDROID_HOME="$ANDROID_SDK_ROOT"
export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"
yes | sdkmanager --licenses >/dev/null
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
flutter config --android-sdk "$ANDROID_SDK_ROOT"
flutter doctor
echo "✅ Setup finished"
