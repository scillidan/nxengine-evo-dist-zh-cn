#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-0.0.0}"
DATA_DIR="${2:-game-data/data}"

REPO_DIR="$(pwd)"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

cd "$WORK_DIR"

echo "=== Cloning NXEngine-evo ==="
git clone --depth=1 "$NXENGINE_REPO" nxengine-evo
cd nxengine-evo

echo "=== Patching upstream for MinGW/GCC 16 compatibility ==="
sed -i 's#\.open(widen(\([^)]*\))#.open(widen(\1).c_str()#g' \
	src/map.cpp src/i18n/translate.cpp src/graphics/Font.cpp \
	src/sound/SoundManager.cpp src/tsc.cpp
sed -i 's#ifstream ifs(widen(\([^)]*\))#ifstream ifs(widen(\1).c_str()#g' \
	src/ResourceManager.cpp

echo "=== Building NXEngine-evo (Windows x64) ==="
export SDL2DIR=/mingw64
export SDL2IMAGEDIR=/mingw64
export SDL2MIXERDIR=/mingw64
export CMAKE_PREFIX_PATH=/mingw64
cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DPORTABLE=ON \
	-DCMAKE_CXX_FLAGS="-DUNICODE -D_UNICODE" -Bbuild -H.
ninja -C build

echo "=== Staging Windows dist ==="
mkdir -p "$REPO_DIR/dist"
OUTPUT_DIR="$REPO_DIR/dist/NXEngine-Evo"
rm -rf "$OUTPUT_DIR"
mkdir "$OUTPUT_DIR"
cp build/nxengine-evo.exe "$OUTPUT_DIR/"
cp build/nxextract.exe "$OUTPUT_DIR/"
cp -r "$REPO_DIR/$DATA_DIR" "$OUTPUT_DIR/data"
cp platform/win32/ext/runtime/x64/*.dll "$OUTPUT_DIR/"

echo "=== Windows dist staged ==="
ls -la "$OUTPUT_DIR"
