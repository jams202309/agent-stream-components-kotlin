#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="${OUTPUT_DIR:-}"

"$ROOT_DIR/scripts/build-rust-android.sh"

cd "$ROOT_DIR"
./gradlew --no-daemon --no-configuration-cache :agent-stream-android:assembleRelease

AAR="$ROOT_DIR/agent-stream-android/build/outputs/aar/agent-stream-android-release.aar"
if [[ ! -f "$AAR" ]]; then
  echo "Expected AAR was not generated: $AAR" >&2
  exit 1
fi

if [[ -n "$OUTPUT_DIR" ]]; then
  mkdir -p "$OUTPUT_DIR"
  cp "$AAR" "$OUTPUT_DIR/agent-stream-android-release.aar"
  echo "Copied AAR to $OUTPUT_DIR/agent-stream-android-release.aar"
else
  echo "Built AAR: $AAR"
fi
