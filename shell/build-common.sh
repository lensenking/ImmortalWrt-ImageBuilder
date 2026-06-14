#!/bin/bash
# ============================================================================
# build-common.sh - Shared utility functions for ImmortalWrt ImageBuilder
# ============================================================================
# Source this file in build scripts:  source shell/build-common.sh

# Create PPPoE configuration file from workflow environment variables
setup_pppoe_config() {
    echo "Create pppoe-settings"
    mkdir -p /home/build/immortalwrt/files/etc/config
    cat << EOF > /home/build/immortalwrt/files/etc/config/pppoe-settings
enable_pppoe=${ENABLE_PPPOE}
pppoe_account=${PPPOE_ACCOUNT}
pppoe_password=${PPPOE_PASSWORD}
EOF
    echo "cat pppoe-settings"
    cat /home/build/immortalwrt/files/etc/config/pppoe-settings
}

# Sync third-party packages from a remote repository
# $1 - repo URL        (e.g. https://github.com/wukongdaily/store.git)
# $2 - local clone dir (e.g. /tmp/store-run-repo)
# $3 - source sub-dir  (e.g. x86, arm64, arm64-a53)
# $4 - package format  (ipk | apk)
sync_third_party_packages() {
    local repo_url="$1"
    local clone_dir="$2"
    local source_subdir="$3"
    local pkg_ext="${4:-ipk}"

    echo "🔄 正在同步第三方软件仓库 Cloning run file repo..."
    git clone --depth=1 "$repo_url" "$clone_dir"

    mkdir -p /home/build/immortalwrt/extra-packages
    cp -r "$clone_dir/run/$source_subdir"/* /home/build/immortalwrt/extra-packages/

    echo "✅ Run files copied to extra-packages:"
    if [ "$pkg_ext" = "ipk" ]; then
        ls -lh /home/build/immortalwrt/extra-packages/*.run 2>/dev/null
        sh shell/prepare-packages.sh
    else
        sh shell/apk-prepare-packages.sh
    fi
    ls -lah /home/build/immortalwrt/packages/
}

# Add aarch64 architecture priority to repositories.conf
add_arch_priority() {
    sed -i '1i\
  arch aarch64_generic 10\n\
  arch aarch64_cortex-a53 15' repositories.conf
}

# Append Docker package to PACKAGES if INCLUDE_DOCKER=yes
add_docker_package() {
    if [ "$INCLUDE_DOCKER" = "yes" ]; then
        PACKAGES="$PACKAGES luci-i18n-dockerman-zh-cn"
        echo "Adding package: luci-i18n-dockerman-zh-cn"
    fi
}

# Download OpenClash core files (clash_meta binary + GeoIP + GeoSite)
# $1 - arch: "amd64" or "arm64"
setup_openclash_core() {
    local arch="$1"

    if ! echo "$PACKAGES" | grep -q "luci-app-openclash"; then
        echo "⚪️ 未选择 luci-app-openclash"
        return
    fi

    echo "✅ 已选择 luci-app-openclash，添加 openclash core"
    mkdir -p files/etc/openclash/core

    local meta_url
    if [ "$arch" = "amd64" ]; then
        meta_url="https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-amd64-v1.tar.gz"
    else
        meta_url="https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-arm64.tar.gz"
    fi

    wget -qO- "$meta_url" | tar xOvz > files/etc/openclash/core/clash_meta
    chmod +x files/etc/openclash/core/clash_meta

    wget -q https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat \
         -O files/etc/openclash/GeoIP.dat
    wget -q https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat \
         -O files/etc/openclash/GeoSite.dat
}

# Download latest OpenClash client package from GitHub releases
# $1 - package format: "ipk" or "apk"
download_openclash_client() {
    local pkg_ext="$1"

    if ! echo "$PACKAGES" | grep -q "luci-app-openclash"; then
        return
    fi

    local url
    url=$(curl -s https://api.github.com/repos/vernesong/OpenClash/releases/latest \
      | grep "browser_download_url.*${pkg_ext}" \
      | head -n1 \
      | cut -d '"' -f 4)
    echo "OpenClash latest ${pkg_ext}: $url"
    wget "$url" -P /home/build/immortalwrt/packages/
}

# Download mihomo core for SSR-Plus
# $1 - arch: "amd64" or "arm64"
setup_mihomo_core() {
    local arch="$1"

    if ! echo "$PACKAGES" | grep -q "luci-app-ssr-plus"; then
        echo "⚪️ 未选择 luci-app-ssr-plus"
        return
    fi

    echo "✅ 已选择 luci-app-ssr-plus，添加 mihomo core"
    mkdir -p files/usr/bin

    local mihomo_arch
    if [ "$arch" = "amd64" ]; then
        mihomo_arch="amd64-compatible"
    else
        mihomo_arch="arm64"
    fi

    local mihomo_url="https://github.com/MetaCubeX/mihomo/releases/download/v1.19.24/mihomo-linux-${mihomo_arch}-v1.19.24.gz"
    wget -qO- "$mihomo_url" | gzip -dc > files/usr/bin/mihomo
    chmod +x files/usr/bin/mihomo
    echo "✅ 已下载 mihomo core"
    ls -lah files/usr/bin
}

# Build firmware image and exit on failure
# Pass all make image arguments directly, e.g.:
#   build_image PROFILE="generic" PACKAGES="$PACKAGES" FILES="..." ROOTFS_PARTSIZE=1024
build_image() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Building image with the following packages:"
    echo "$PACKAGES"

    make image "$@"

    if [ $? -ne 0 ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Error: Build failed!"
        exit 1
    fi

    echo "$(date '+%Y-%m-%d %H:%M:%S') - Build completed successfully."
}
