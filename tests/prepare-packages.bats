#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'
load 'test_helper/bats-file/load'

setup() {
    TEST_TMPDIR="$(mktemp -d)"
    mkdir -p "$TEST_TMPDIR/work/extra-packages"
}

teardown() {
    rm -rf "$TEST_TMPDIR"
}

# ── prepare-packages.sh (ipk) ─────────────────────────────────

@test "prepare-packages: creates packages output directory" {
    cd "$TEST_TMPDIR/work"

    cat > prepare.sh <<'SCRIPT'
#!/bin/sh
BASE_DIR="extra-packages"
TEMP_DIR="$BASE_DIR/temp-unpack"
TARGET_DIR="packages"
rm -rf "$TEMP_DIR" "$TARGET_DIR"
mkdir -p "$TEMP_DIR" "$TARGET_DIR"
for run_file in "$BASE_DIR"/*.run; do
    [ -e "$run_file" ] || continue
done
find "$TEMP_DIR" -type f -name "*.ipk" -exec cp -v {} "$TARGET_DIR"/ \;
find "$BASE_DIR" -mindepth 2 -maxdepth 2 -type f -name "*.ipk" ! -path "$TEMP_DIR/*" \
  -exec cp -v {} "$TARGET_DIR"/ \;
SCRIPT

    bash prepare.sh

    assert [ -d "packages" ]
}

@test "prepare-packages: collects ipk files from subdirectories" {
    cd "$TEST_TMPDIR/work"

    mkdir -p extra-packages/subdir1
    touch extra-packages/subdir1/package-a.ipk
    touch extra-packages/subdir1/package-b.ipk

    cat > prepare.sh <<'SCRIPT'
#!/bin/sh
BASE_DIR="extra-packages"
TEMP_DIR="$BASE_DIR/temp-unpack"
TARGET_DIR="packages"
rm -rf "$TEMP_DIR" "$TARGET_DIR"
mkdir -p "$TEMP_DIR" "$TARGET_DIR"
for run_file in "$BASE_DIR"/*.run; do
    [ -e "$run_file" ] || continue
done
find "$TEMP_DIR" -type f -name "*.ipk" -exec cp -v {} "$TARGET_DIR"/ \;
find "$BASE_DIR" -mindepth 2 -maxdepth 2 -type f -name "*.ipk" ! -path "$TEMP_DIR/*" \
  -exec cp -v {} "$TARGET_DIR"/ \;
SCRIPT

    bash prepare.sh

    assert [ -f "packages/package-a.ipk" ]
    assert [ -f "packages/package-b.ipk" ]
}

@test "prepare-packages: ignores non-ipk files in subdirectories" {
    cd "$TEST_TMPDIR/work"

    mkdir -p extra-packages/subdir1
    touch extra-packages/subdir1/package-a.ipk
    touch extra-packages/subdir1/readme.txt

    cat > prepare.sh <<'SCRIPT'
#!/bin/sh
BASE_DIR="extra-packages"
TEMP_DIR="$BASE_DIR/temp-unpack"
TARGET_DIR="packages"
rm -rf "$TEMP_DIR" "$TARGET_DIR"
mkdir -p "$TEMP_DIR" "$TARGET_DIR"
for run_file in "$BASE_DIR"/*.run; do
    [ -e "$run_file" ] || continue
done
find "$TEMP_DIR" -type f -name "*.ipk" -exec cp -v {} "$TARGET_DIR"/ \;
find "$BASE_DIR" -mindepth 2 -maxdepth 2 -type f -name "*.ipk" ! -path "$TEMP_DIR/*" \
  -exec cp -v {} "$TARGET_DIR"/ \;
SCRIPT

    bash prepare.sh

    assert [ -f "packages/package-a.ipk" ]
    assert [ ! -f "packages/readme.txt" ]
}

@test "prepare-packages: cleans old directories before run" {
    cd "$TEST_TMPDIR/work"

    # Pre-create stale directories
    mkdir -p packages
    touch packages/old-stale.ipk
    mkdir -p extra-packages/temp-unpack
    touch extra-packages/temp-unpack/old-temp.ipk

    cat > prepare.sh <<'SCRIPT'
#!/bin/sh
BASE_DIR="extra-packages"
TEMP_DIR="$BASE_DIR/temp-unpack"
TARGET_DIR="packages"
rm -rf "$TEMP_DIR" "$TARGET_DIR"
mkdir -p "$TEMP_DIR" "$TARGET_DIR"
for run_file in "$BASE_DIR"/*.run; do
    [ -e "$run_file" ] || continue
done
find "$TEMP_DIR" -type f -name "*.ipk" -exec cp -v {} "$TARGET_DIR"/ \;
find "$BASE_DIR" -mindepth 2 -maxdepth 2 -type f -name "*.ipk" ! -path "$TEMP_DIR/*" \
  -exec cp -v {} "$TARGET_DIR"/ \;
SCRIPT

    bash prepare.sh

    assert [ ! -f "packages/old-stale.ipk" ]
    assert [ ! -f "extra-packages/temp-unpack/old-temp.ipk" ]
}

@test "prepare-packages: skips .run loop when no .run files" {
    cd "$TEST_TMPDIR/work"

    cat > prepare.sh <<'SCRIPT'
#!/bin/sh
BASE_DIR="extra-packages"
TEMP_DIR="$BASE_DIR/temp-unpack"
TARGET_DIR="packages"
rm -rf "$TEMP_DIR" "$TARGET_DIR"
mkdir -p "$TEMP_DIR" "$TARGET_DIR"
for run_file in "$BASE_DIR"/*.run; do
    [ -e "$run_file" ] || continue
    echo "SHOULD_NOT_APPEAR"
done
SCRIPT

    run bash prepare.sh
    assert_success
    refute_output --partial "SHOULD_NOT_APPEAR"
}

# ── apk-prepare-packages.sh ──────────────────────────────────

@test "apk-prepare-packages: collects apk files from subdirectories" {
    cd "$TEST_TMPDIR/work"

    mkdir -p extra-packages/subdir1
    touch extra-packages/subdir1/tool-a.apk
    touch extra-packages/subdir1/tool-b.apk

    cat > prepare_apk.sh <<'SCRIPT'
#!/bin/sh
BASE_DIR="extra-packages"
TEMP_DIR="$BASE_DIR/temp-unpack"
TARGET_DIR="packages"
rm -rf "$TEMP_DIR" "$TARGET_DIR"
mkdir -p "$TEMP_DIR" "$TARGET_DIR"
for run_file in "$BASE_DIR"/*.run; do
    [ -e "$run_file" ] || continue
done
find "$TEMP_DIR" -type f -name "*.apk" -exec cp -v {} "$TARGET_DIR"/ \;
find "$BASE_DIR" -mindepth 2 -maxdepth 2 -type f -name "*.apk" ! -path "$TEMP_DIR/*" \
  -exec cp -v {} "$TARGET_DIR"/ \;
SCRIPT

    bash prepare_apk.sh

    assert [ -f "packages/tool-a.apk" ]
    assert [ -f "packages/tool-b.apk" ]
}

@test "apk-prepare-packages: ignores ipk files (only collects apk)" {
    cd "$TEST_TMPDIR/work"

    mkdir -p extra-packages/subdir1
    touch extra-packages/subdir1/tool-a.apk
    touch extra-packages/subdir1/wrong.ipk

    cat > prepare_apk.sh <<'SCRIPT'
#!/bin/sh
BASE_DIR="extra-packages"
TEMP_DIR="$BASE_DIR/temp-unpack"
TARGET_DIR="packages"
rm -rf "$TEMP_DIR" "$TARGET_DIR"
mkdir -p "$TEMP_DIR" "$TARGET_DIR"
for run_file in "$BASE_DIR"/*.run; do
    [ -e "$run_file" ] || continue
done
find "$TEMP_DIR" -type f -name "*.apk" -exec cp -v {} "$TARGET_DIR"/ \;
find "$BASE_DIR" -mindepth 2 -maxdepth 2 -type f -name "*.apk" ! -path "$TEMP_DIR/*" \
  -exec cp -v {} "$TARGET_DIR"/ \;
SCRIPT

    bash prepare_apk.sh

    assert [ -f "packages/tool-a.apk" ]
    assert [ ! -f "packages/wrong.ipk" ]
}

@test "apk-prepare-packages: does not collect files deeper than maxdepth 2" {
    cd "$TEST_TMPDIR/work"

    mkdir -p extra-packages/subdir1/deep
    touch extra-packages/subdir1/shallow.apk
    touch extra-packages/subdir1/deep/too-deep.apk

    cat > prepare_apk.sh <<'SCRIPT'
#!/bin/sh
BASE_DIR="extra-packages"
TEMP_DIR="$BASE_DIR/temp-unpack"
TARGET_DIR="packages"
rm -rf "$TEMP_DIR" "$TARGET_DIR"
mkdir -p "$TEMP_DIR" "$TARGET_DIR"
for run_file in "$BASE_DIR"/*.run; do
    [ -e "$run_file" ] || continue
done
find "$TEMP_DIR" -type f -name "*.apk" -exec cp -v {} "$TARGET_DIR"/ \;
find "$BASE_DIR" -mindepth 2 -maxdepth 2 -type f -name "*.apk" ! -path "$TEMP_DIR/*" \
  -exec cp -v {} "$TARGET_DIR"/ \;
SCRIPT

    bash prepare_apk.sh

    assert [ -f "packages/shallow.apk" ]
    assert [ ! -f "packages/too-deep.apk" ]
}

@test "apk-prepare-packages: excludes temp-unpack from collection" {
    cd "$TEST_TMPDIR/work"

    mkdir -p extra-packages/temp-unpack
    touch extra-packages/temp-unpack/from-temp.apk
    mkdir -p extra-packages/subdir1
    touch extra-packages/subdir1/regular.apk

    cat > prepare_apk.sh <<'SCRIPT'
#!/bin/sh
BASE_DIR="extra-packages"
TEMP_DIR="$BASE_DIR/temp-unpack"
TARGET_DIR="packages"
rm -rf "$TEMP_DIR" "$TARGET_DIR"
mkdir -p "$TEMP_DIR" "$TARGET_DIR"
for run_file in "$BASE_DIR"/*.run; do
    [ -e "$run_file" ] || continue
done
find "$TEMP_DIR" -type f -name "*.apk" -exec cp -v {} "$TARGET_DIR"/ \;
find "$BASE_DIR" -mindepth 2 -maxdepth 2 -type f -name "*.apk" ! -path "$TEMP_DIR/*" \
  -exec cp -v {} "$TARGET_DIR"/ \;
SCRIPT

    bash prepare_apk.sh

    # temp-unpack is rm -rf'd and recreated empty, so from-temp.apk should be gone
    assert [ ! -f "packages/from-temp.apk" ]
    assert [ -f "packages/regular.apk" ]
}
