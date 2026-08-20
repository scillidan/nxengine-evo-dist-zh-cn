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
cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DPORTABLE=ON \
	-DCMAKE_INSTALL_PREFIX=/usr -Bbuild -H.
ninja -C build

echo "=== Assembling AppDir ==="
rm -rf AppDir
DESTDIR=AppDir ninja -C build install
rm -rf AppDir/usr/share/nxengine/data
cp -r "$REPO_DIR/$DATA_DIR" AppDir/usr/bin/data

echo "=== Building AppImage (${ARCH}) ==="
export APPIMAGE_EXTRACT_AND_RUN=1
export ARCH="$ARCH"
export OUTPUT="NXEngine-Evo-${VERSION}-Linux-${ARCH}.AppImage"
export PATH="$(pwd):$PATH"

LD="linuxdeploy-${ARCH}.AppImage"
wget -q "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/${LD}" -O "$LD"
chmod +x "$LD"
wget -q "https://github.com/linuxdeploy/linuxdeploy-plugin-appimage/releases/download/continuous/linuxdeploy-plugin-appimage-${ARCH}.AppImage" -O "linuxdeploy-plugin-appimage.AppImage"
chmod +x "linuxdeploy-plugin-appimage.AppImage"

"./$LD" --appdir AppDir --output appimage

mkdir -p "$REPO_DIR/dist"
cp "$OUTPUT" "$REPO_DIR/dist/"

echo "=== Linux dist ready ==="
ls -la "$REPO_DIR/dist"
