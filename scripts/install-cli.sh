#!/bin/bash
set -euo pipefail

usage() { echo "Usage: scripts/install-cli.sh [prefix-directory]"; }
if [ "$#" -eq 1 ] && { [ "$1" = --help ] || [ "$1" = -h ]; }; then
    usage
    exit 0
fi
if [ "$#" -gt 1 ] || { [ "$#" -eq 1 ] && { [ -z "$1" ] || [[ "$1" = -* ]]; }; }; then
    usage >&2
    exit 2
fi
if [ "$(uname -s)" != Darwin ]; then
    echo "Claudock requires macOS to build." >&2
    exit 1
fi

ROOT=$(cd "$(dirname "$0")/.." && pwd)
PREFIX=${1:-"$HOME/.local/bin"}
if [ -z "${DEVELOPER_DIR:-}" ] && [ -d /Applications/Xcode.app/Contents/Developer ]; then
    export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
fi

STAGE=$(mktemp -d "${TMPDIR:-/private/tmp}/claudock-cli.XXXXXX")
trap 'rm -rf "$STAGE"' EXIT
export CLANG_MODULE_CACHE_PATH="$STAGE/.mc"
BUILD_FLAGS=(--scratch-path "$STAGE/.build" --cache-path "$STAGE/.swiftpm-cache"
    --config-path "$STAGE/.swiftpm-config" --security-path "$STAGE/.swiftpm-security"
    -Xswiftc -module-cache-path -Xswiftc "$STAGE/.mc")
xcrun swift build --package-path "$ROOT" -c release --product claudock "${BUILD_FLAGS[@]}"
BINARY_DIR=$(xcrun swift build --package-path "$ROOT" -c release "${BUILD_FLAGS[@]}" --show-bin-path)
mkdir -p "$PREFIX"
/usr/bin/install -m 755 "$BINARY_DIR/claudock" "$PREFIX/claudock"
echo "Installed: $PREFIX/claudock"
echo "Add the prefix directory to PATH if it is not already there."
