#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    source "${BATS_TEST_DIRNAME}/../shell/lib/network-helpers.sh"
    TEST_TMPDIR="$(mktemp -d)"
}

teardown() {
    rm -rf "$TEST_TMPDIR"
}

# ── detect_interfaces ──────────────────────────────────────────

@test "detect_interfaces: returns eth interfaces with device symlink" {
    mkdir -p "$TEST_TMPDIR/sysnet/eth0" "$TEST_TMPDIR/sysnet/eth1"
    ln -s /dev/null "$TEST_TMPDIR/sysnet/eth0/device"
    ln -s /dev/null "$TEST_TMPDIR/sysnet/eth1/device"

    run detect_interfaces "$TEST_TMPDIR/sysnet"
    assert_success
    assert_output "eth0 eth1"
}

@test "detect_interfaces: returns en-prefixed interfaces" {
    mkdir -p "$TEST_TMPDIR/sysnet/enp0s3"
    ln -s /dev/null "$TEST_TMPDIR/sysnet/enp0s3/device"

    run detect_interfaces "$TEST_TMPDIR/sysnet"
    assert_success
    assert_output "enp0s3"
}

@test "detect_interfaces: skips lo and wlan (no eth/en prefix)" {
    mkdir -p "$TEST_TMPDIR/sysnet/lo" "$TEST_TMPDIR/sysnet/wlan0" "$TEST_TMPDIR/sysnet/eth0"
    ln -s /dev/null "$TEST_TMPDIR/sysnet/lo/device"
    ln -s /dev/null "$TEST_TMPDIR/sysnet/wlan0/device"
    ln -s /dev/null "$TEST_TMPDIR/sysnet/eth0/device"

    run detect_interfaces "$TEST_TMPDIR/sysnet"
    assert_success
    assert_output "eth0"
}

@test "detect_interfaces: skips interfaces without device symlink" {
    mkdir -p "$TEST_TMPDIR/sysnet/eth0" "$TEST_TMPDIR/sysnet/eth1"
    ln -s /dev/null "$TEST_TMPDIR/sysnet/eth0/device"
    # eth1 has no device symlink

    run detect_interfaces "$TEST_TMPDIR/sysnet"
    assert_success
    assert_output "eth0"
}

@test "detect_interfaces: returns empty string when no interfaces" {
    mkdir -p "$TEST_TMPDIR/sysnet/lo"

    run detect_interfaces "$TEST_TMPDIR/sysnet"
    assert_success
    assert_output ""
}

@test "detect_interfaces: handles mixed eth and en interfaces" {
    mkdir -p "$TEST_TMPDIR/sysnet/eth0" "$TEST_TMPDIR/sysnet/enp1s0" "$TEST_TMPDIR/sysnet/br-lan"
    ln -s /dev/null "$TEST_TMPDIR/sysnet/eth0/device"
    ln -s /dev/null "$TEST_TMPDIR/sysnet/enp1s0/device"
    ln -s /dev/null "$TEST_TMPDIR/sysnet/br-lan/device"

    run detect_interfaces "$TEST_TMPDIR/sysnet"
    assert_success
    assert_output "enp1s0 eth0"
}

# ── map_interfaces ─────────────────────────────────────────────

@test "map_interfaces: radxa,e20c swaps WAN=eth1 LAN=eth0" {
    run map_interfaces "radxa,e20c" "eth0 eth1"
    assert_success
    assert_line --index 0 "eth1"
    assert_line --index 1 "eth0"
}

@test "map_interfaces: friendlyarm,nanopi-r5c swaps WAN=eth1 LAN=eth0" {
    run map_interfaces "friendlyarm,nanopi-r5c" "eth0 eth1"
    assert_success
    assert_line --index 0 "eth1"
    assert_line --index 1 "eth0"
}

@test "map_interfaces: default board uses first iface as WAN, rest as LAN" {
    run map_interfaces "generic-x86" "eth0 eth1 eth2"
    assert_success
    assert_line --index 0 "eth0"
    assert_line --index 1 "eth1 eth2"
}

@test "map_interfaces: single interface default mapping" {
    run map_interfaces "unknown-board" "eth0"
    assert_success
    assert_line --index 0 "eth0"
}

# ── get_network_mode ───────────────────────────────────────────

@test "get_network_mode: returns single for count=1" {
    run get_network_mode 1
    assert_success
    assert_output "single"
}

@test "get_network_mode: returns multi for count=2" {
    run get_network_mode 2
    assert_success
    assert_output "multi"
}

@test "get_network_mode: returns multi for count=4" {
    run get_network_mode 4
    assert_success
    assert_output "multi"
}

@test "get_network_mode: returns none for count=0" {
    run get_network_mode 0
    assert_success
    assert_output "none"
}

@test "get_network_mode: returns none for non-numeric input" {
    run get_network_mode "abc"
    assert_success
    assert_output "none"
}

# ── get_router_ip ──────────────────────────────────────────────

@test "get_router_ip: reads IP from file" {
    echo "10.0.0.1" > "$TEST_TMPDIR/ip.txt"

    run get_router_ip "$TEST_TMPDIR/ip.txt"
    assert_success
    assert_output "10.0.0.1"
}

@test "get_router_ip: returns default when file missing" {
    run get_router_ip "$TEST_TMPDIR/nonexistent.txt"
    assert_success
    assert_output "192.168.100.1"
}

# ── is_pppoe_enabled ──────────────────────────────────────────

@test "is_pppoe_enabled: returns 0 for 'yes'" {
    run is_pppoe_enabled "yes"
    assert_success
}

@test "is_pppoe_enabled: returns 1 for 'no'" {
    run is_pppoe_enabled "no"
    assert_failure
}

@test "is_pppoe_enabled: returns 1 for empty string" {
    run is_pppoe_enabled ""
    assert_failure
}

# ── validate_pppoe_credentials ─────────────────────────────────

@test "validate_pppoe_credentials: succeeds with both account and password" {
    run validate_pppoe_credentials "user@isp" "secret123"
    assert_success
}

@test "validate_pppoe_credentials: fails with empty account" {
    run validate_pppoe_credentials "" "secret123"
    assert_failure
}

@test "validate_pppoe_credentials: fails with empty password" {
    run validate_pppoe_credentials "user@isp" ""
    assert_failure
}

@test "validate_pppoe_credentials: fails with both empty" {
    run validate_pppoe_credentials "" ""
    assert_failure
}

# ── parse_pppoe_settings ──────────────────────────────────────

@test "parse_pppoe_settings: reads existing settings file" {
    cat > "$TEST_TMPDIR/pppoe-settings" <<EOF
enable_pppoe=yes
pppoe_account=myuser
pppoe_password=mypass
EOF

    run parse_pppoe_settings "$TEST_TMPDIR/pppoe-settings"
    assert_success
    assert_line "enable_pppoe=yes"
    assert_line "pppoe_account=myuser"
    assert_line "pppoe_password=mypass"
}

@test "parse_pppoe_settings: fails when file missing" {
    run parse_pppoe_settings "$TEST_TMPDIR/nonexistent"
    assert_failure
}
