#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    source "${BATS_TEST_DIRNAME}/../shell/lib/build-helpers.sh"
}

# ── build_base_packages ────────────────────────────────────────

@test "build_base_packages: v25 includes package-manager" {
    run build_base_packages "25"
    assert_success
    assert_output --partial "luci-i18n-package-manager-zh-cn"
}

@test "build_base_packages: v24 includes package-manager" {
    run build_base_packages "24"
    assert_success
    assert_output --partial "luci-i18n-package-manager-zh-cn"
}

@test "build_base_packages: v23 omits package-manager" {
    run build_base_packages "23"
    assert_success
    refute_output --partial "luci-i18n-package-manager-zh-cn"
}

@test "build_base_packages: always includes curl" {
    run build_base_packages "25"
    assert_success
    assert_output --partial "curl"
}

@test "build_base_packages: always includes argon theme" {
    run build_base_packages "23"
    assert_success
    assert_output --partial "luci-theme-argon"
}

@test "build_base_packages: always includes ttyd" {
    run build_base_packages "24"
    assert_success
    assert_output --partial "luci-i18n-ttyd-zh-cn"
}

@test "build_base_packages: always includes sftp server" {
    run build_base_packages "25"
    assert_success
    assert_output --partial "openssh-sftp-server"
}

@test "build_base_packages: always includes filemanager" {
    run build_base_packages "25"
    assert_success
    assert_output --partial "luci-i18n-filemanager-zh-cn"
}

@test "build_base_packages: always includes diskman" {
    run build_base_packages "24"
    assert_success
    assert_output --partial "luci-i18n-diskman-zh-cn"
}

@test "build_base_packages: always includes firewall i18n" {
    run build_base_packages "23"
    assert_success
    assert_output --partial "luci-i18n-firewall-zh-cn"
}

# ── append_docker_package ──────────────────────────────────────

@test "append_docker_package: adds dockerman when yes" {
    run append_docker_package "curl luci-theme-argon" "yes"
    assert_success
    assert_output --partial "luci-i18n-dockerman-zh-cn"
    assert_output --partial "curl"
}

@test "append_docker_package: skips dockerman when no" {
    run append_docker_package "curl luci-theme-argon" "no"
    assert_success
    refute_output --partial "luci-i18n-dockerman-zh-cn"
}

@test "append_docker_package: skips dockerman when empty" {
    run append_docker_package "curl" ""
    assert_success
    refute_output --partial "luci-i18n-dockerman-zh-cn"
}

# ── has_openclash ──────────────────────────────────────────────

@test "has_openclash: detects openclash in package list" {
    run has_openclash "curl luci-app-openclash luci-theme-argon"
    assert_success
}

@test "has_openclash: returns false when absent" {
    run has_openclash "curl luci-theme-argon"
    assert_failure
}

# ── has_ssr_plus ───────────────────────────────────────────────

@test "has_ssr_plus: detects ssr-plus in package list" {
    run has_ssr_plus "curl luci-app-ssr-plus luci-i18n-ssr-plus-zh-cn"
    assert_success
}

@test "has_ssr_plus: returns false when absent" {
    run has_ssr_plus "curl luci-theme-argon"
    assert_failure
}

# ── get_openclash_meta_url ─────────────────────────────────────

@test "get_openclash_meta_url: amd64 URL" {
    run get_openclash_meta_url "amd64"
    assert_success
    assert_output "https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-amd64.tar.gz"
}

@test "get_openclash_meta_url: arm64 URL" {
    run get_openclash_meta_url "arm64"
    assert_success
    assert_output "https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-arm64.tar.gz"
}

# ── get_mihomo_url ─────────────────────────────────────────────

@test "get_mihomo_url: amd64 includes -compatible suffix" {
    run get_mihomo_url "amd64"
    assert_success
    assert_output "https://github.com/MetaCubeX/mihomo/releases/download/v1.19.24/mihomo-linux-amd64-compatible-v1.19.24.gz"
}

@test "get_mihomo_url: arm64 has no -compatible suffix" {
    run get_mihomo_url "arm64"
    assert_success
    assert_output "https://github.com/MetaCubeX/mihomo/releases/download/v1.19.24/mihomo-linux-arm64-v1.19.24.gz"
}

@test "get_mihomo_url: custom version" {
    run get_mihomo_url "arm64" "v2.0.0"
    assert_success
    assert_output "https://github.com/MetaCubeX/mihomo/releases/download/v2.0.0/mihomo-linux-arm64-v2.0.0.gz"
}

# ── generate_pppoe_config ─────────────────────────────────────

@test "generate_pppoe_config: generates correct config" {
    run generate_pppoe_config "yes" "user@isp" "secret"
    assert_success
    assert_line "enable_pppoe=yes"
    assert_line "pppoe_account=user@isp"
    assert_line "pppoe_password=secret"
}

@test "generate_pppoe_config: handles disabled pppoe" {
    run generate_pppoe_config "no" "" ""
    assert_success
    assert_line "enable_pppoe=no"
    assert_line "pppoe_account="
    assert_line "pppoe_password="
}

# ── merge_packages ─────────────────────────────────────────────

@test "merge_packages: combines base and custom" {
    run merge_packages "curl luci-theme-argon" "luci-app-openclash"
    assert_success
    assert_output "curl luci-theme-argon luci-app-openclash"
}

@test "merge_packages: handles empty custom" {
    run merge_packages "curl" ""
    assert_success
    assert_output "curl"
}

@test "merge_packages: handles empty base" {
    run merge_packages "" "luci-app-openclash"
    assert_success
    assert_output "luci-app-openclash"
}

# ── get_package_extension ──────────────────────────────────────

@test "get_package_extension: v25 uses apk" {
    run get_package_extension "25"
    assert_success
    assert_output "apk"
}

@test "get_package_extension: v24 uses ipk" {
    run get_package_extension "24"
    assert_success
    assert_output "ipk"
}

@test "get_package_extension: v23 uses ipk" {
    run get_package_extension "23"
    assert_success
    assert_output "ipk"
}

# ── get_store_repo_url ─────────────────────────────────────────

@test "get_store_repo_url: v25 uses apk repo" {
    run get_store_repo_url "25"
    assert_success
    assert_output "https://github.com/wukongdaily/apk.git"
}

@test "get_store_repo_url: v24 uses store repo" {
    run get_store_repo_url "24"
    assert_success
    assert_output "https://github.com/wukongdaily/store.git"
}

@test "get_store_repo_url: v23 uses store repo" {
    run get_store_repo_url "23"
    assert_success
    assert_output "https://github.com/wukongdaily/store.git"
}
