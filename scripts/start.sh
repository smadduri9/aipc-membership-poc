#!/usr/bin/env bash
# Starts the app with one command.
#   ./scripts/start.sh          runs in Chrome (works on macOS, Windows via Git Bash, and Linux)
#   ./scripts/start.sh ios      runs in the iOS Simulator (macOS with Xcode only)
set -euo pipefail
cd "$(dirname "$0")/.."

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter is not installed or not on PATH."
  echo "Install the stable channel: https://docs.flutter.dev/get-started/install"
  exit 1
fi

target="${1:-chrome}"
flutter pub get

if [ "$target" = "ios" ]; then
  open -a Simulator
  # Give the simulator a moment to boot before Flutter looks for it.
  sleep 5
  flutter run -d "$(xcrun simctl list devices booted | grep -m1 -oE '[0-9A-F-]{36}')"
else
  flutter run -d chrome
fi
