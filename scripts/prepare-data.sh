#!/usr/bin/env bash
set -euo pipefail

FONT_NAME="${1:-ark-pixel-12px-monospaced-zh_cn.ttf}"
VERSION="${2:-0.0.0}"

REPO_DIR="$(pwd)"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

cd "$WORK_DIR"

echo "=== Cloning translations ==="
git clone --depth=1 "$TRANSLATIONS_REPO" translations
cd translations

echo "=== Cloning Chinese translation ==="
git clone --depth=1 "$LANG_CHINESE_REPO" local/lang_chinese

echo "=== Replacing font in metadata ==="
sed -i "s|assets/unifont-10.0.06.ttf|assets/${FONT_NAME}|" local/lang_chinese/metadata
mkdir -p local/assets
cp "$REPO_DIR/font/${FONT_NAME}" "local/assets/${FONT_NAME}"

echo "=== Building localized data ==="
bash build-local.sh

echo "=== Cloning NXEngine-evo ==="
cd "$WORK_DIR"
git clone --depth=1 "$NXENGINE_REPO" nxengine-evo
cd nxengine-evo

echo "=== Building nxextract ==="
cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DPORTABLE=ON -Bbuild -H.
ninja -C build extract

echo "=== Downloading Cave Story ==="
cd "$WORK_DIR"
wget -q "$CAVESTORY_URL" -O cavestoryen.zip
unzip -q cavestoryen.zip

echo "=== Merging game data ==="
cd nxengine-evo
cp -r "$WORK_DIR/CaveStory/data/." data/
cp -r "$WORK_DIR/translations/local/data/lang/chinese/." data/
cp "$WORK_DIR/CaveStory/Doukutsu.exe" .

echo "=== Running nxextract ==="
./build/nxextract

echo "=== Packaging data ==="
mkdir -p "$REPO_DIR/dist"
cp -r data "$REPO_DIR/dist/data"

echo "=== Data ready ==="
ls -la "$REPO_DIR/dist/data"
