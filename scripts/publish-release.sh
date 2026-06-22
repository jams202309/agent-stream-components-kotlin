#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

VERSION_NAME="${VERSION_NAME:-${1:-}}"
if [[ -z "$VERSION_NAME" ]]; then
  echo "Usage: VERSION_NAME=<version> AGENT_STREAM_SDK_REF=<ref> scripts/publish-release.sh" >&2
  echo "   or: scripts/publish-release.sh <version>" >&2
  exit 1
fi

if [[ -z "${GITHUB_TOKEN:-${GH_TOKEN:-${PACKAGES_TOKEN:-${PRIVATE_REGISTRY_TOKEN:-}}}}" ]]; then
  echo "A GitHub Packages token is required. Set GITHUB_TOKEN, GH_TOKEN, PACKAGES_TOKEN, or PRIVATE_REGISTRY_TOKEN." >&2
  exit 1
fi

"$ROOT_DIR/scripts/build-rust-android.sh"

cd "$ROOT_DIR"
./gradlew --no-daemon --no-configuration-cache \
  :agent-stream-android:publishAgentStreamAndroidPublicationToGitHubPackagesRepository \
  -PversionName="$VERSION_NAME" \
  -PagentStreamSdkRef="${AGENT_STREAM_SDK_REF:-main}"
