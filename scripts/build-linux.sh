#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-0.0.0}"
ARCH="${2:-x86_64}"
DATA_DIR="${3:-game-data/data}"

REPO_DIR="$(pwd)"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

cd "$WORK_DIR"

echo "=== Cloning NXEngine-evo ==="
git clone --depth=1 "$NXENGINE_REPO" nxengine-evo
cd nxengine-evo

echo "=== Building NXEngine-evo (Linux ${ARCH}) ==="
cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DPORTABLE=ON -Bbuild -H.
ninja -C build

echo "=== Packaging Linux dist ==="
mkdir -p "$REPO_DIR/dist"
OUTPUT_DIR="NXEngine-Evo"
mkdir "$OUTPUT_DIR"
cp build/nxengine-evo "$OUTPUT_DIR/"
cp build/nxextract "$OUTPUT_DIR/"
cp -r "$REPO_DIR/$DATA_DIR" "$OUTPUT_DIR/data"
chmod +x "$OUTPUT_DIR/nxengine-evo" "$OUTPUT_DIR/nxextract"

ARCHIVE="$REPO_DIR/dist/NXEngine-Evo-${VERSION}-Linux-${ARCH}.tar.gz"
tar czf "$ARCHIVE" "$OUTPUT_DIR"

echo "=== Linux dist ready ==="
ls -la "$REPO_DIR/dist"
