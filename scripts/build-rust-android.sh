#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODULE_DIR="$ROOT_DIR/agent-stream-android"
JNI_LIBS_DIR="$MODULE_DIR/src/main/jniLibs"

SDK_REPO="${AGENT_STREAM_SDK_REPO:-https://github.com/unseal-network/agent-stream-sdk.git}"
SDK_REF="${AGENT_STREAM_SDK_REF:-main}"
SDK_DIR="${AGENT_STREAM_SDK_DIR:-$ROOT_DIR/.checkout/agent-stream-sdk}"
ANDROID_PLATFORM="${ANDROID_PLATFORM:-26}"
RUST_TOOLCHAIN="${RUST_TOOLCHAIN:-stable}"
CARGO_BIN="${CARGO_BIN:-$HOME/.cargo/bin/cargo}"

export PATH="$HOME/.cargo/bin:$PATH"
export RUSTUP_TOOLCHAIN="$RUST_TOOLCHAIN"

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

require_cmd git
if [[ ! -x "$CARGO_BIN" ]]; then
  echo "Missing rustup cargo proxy at $CARGO_BIN" >&2
  exit 1
fi
require_cmd rustup

if ! "$CARGO_BIN" "+$RUST_TOOLCHAIN" ndk --version >/dev/null 2>&1; then
  echo "Missing cargo-ndk. Install it with: cargo install cargo-ndk" >&2
  exit 1
fi

if [[ ! -d "$SDK_DIR/.git" ]]; then
  rm -rf "$SDK_DIR"
  mkdir -p "$(dirname "$SDK_DIR")"
  git clone "$SDK_REPO" "$SDK_DIR"
fi

git -C "$SDK_DIR" fetch --tags origin
if git -C "$SDK_DIR" rev-parse --verify --quiet "$SDK_REF^{commit}" >/dev/null; then
  git -C "$SDK_DIR" checkout "$SDK_REF"
else
  git -C "$SDK_DIR" fetch origin "$SDK_REF"
  git -C "$SDK_DIR" checkout FETCH_HEAD
fi

rustup target add --toolchain "$RUST_TOOLCHAIN" \
  aarch64-linux-android \
  armv7-linux-androideabi \
  i686-linux-android \
  x86_64-linux-android

rm -rf "$JNI_LIBS_DIR"
mkdir -p "$JNI_LIBS_DIR"

cd "$SDK_DIR"

"$CARGO_BIN" "+$RUST_TOOLCHAIN" ndk \
  --target aarch64-linux-android \
  --target armv7-linux-androideabi \
  --target i686-linux-android \
  --target x86_64-linux-android \
  --platform "$ANDROID_PLATFORM" \
  -o "$JNI_LIBS_DIR" \
  build --release -p unseal-agent-stream

for abi in arm64-v8a armeabi-v7a x86 x86_64; do
  lib="$JNI_LIBS_DIR/$abi/libunseal_agent_stream.so"
  if [[ ! -f "$lib" ]]; then
    echo "Expected native library was not generated: $lib" >&2
    exit 1
  fi
done

echo "Built native libraries into $JNI_LIBS_DIR"
