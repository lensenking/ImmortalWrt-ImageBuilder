#!/bin/sh
# Common logic for preparing third-party packages (ipk or apk)
# $1 - package extension: "ipk" or "apk"

PKG_EXT="${1:-ipk}"

BASE_DIR="extra-packages"
TEMP_DIR="$BASE_DIR/temp-unpack"
TARGET_DIR="packages"

rm -rf "$TEMP_DIR" "$TARGET_DIR"
mkdir -p "$TEMP_DIR" "$TARGET_DIR"

for run_file in "$BASE_DIR"/*.run; do
    [ -e "$run_file" ] || continue
    echo "🧩 解压 $run_file -> $TEMP_DIR"
    sh "$run_file" --target "$TEMP_DIR" --noexec
done

find "$TEMP_DIR" -type f -name "*.${PKG_EXT}" -exec cp -v {} "$TARGET_DIR"/ \;

find "$BASE_DIR" -mindepth 2 -maxdepth 2 -type f -name "*.${PKG_EXT}" ! -path "$TEMP_DIR/*" \
  -exec echo "👉 Found:" {} \; \
  -exec cp -v {} "$TARGET_DIR"/ \;

echo "✅ 所有 .${PKG_EXT} 文件已整理至 $TARGET_DIR/"
