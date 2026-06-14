#!/bin/bash
# Extracted helper functions from the build scripts (x86-64/build*.sh, rockchip/build*.sh, etc.)
# These functions encapsulate testable build configuration logic.

# Build the base package list common to most targets.
# Args: $1=version ("23"|"24"|"25")
# Outputs the PACKAGES string.
build_base_packages() {
    local version="$1"
    local packages=""
    packages="$packages curl"
    packages="$packages luci-i18n-diskman-zh-cn"
    packages="$packages luci-i18n-firewall-zh-cn"
    packages="$packages luci-theme-argon"
    packages="$packages luci-app-argon-config"
    packages="$packages luci-i18n-argon-config-zh-cn"

    if [ "$version" = "24" ] || [ "$version" = "25" ]; then
        packages="$packages luci-i18n-package-manager-zh-cn"
    fi

    packages="$packages luci-i18n-ttyd-zh-cn"
    packages="$packages openssh-sftp-server"
    packages="$packages luci-i18n-filemanager-zh-cn"

    echo "$packages" | awk '{$1=$1};1'
}

# Append Docker package if requested.
# Args: $1=current packages  $2=include_docker flag ("yes"|"no")
# Outputs the updated PACKAGES string.
append_docker_package() {
    local packages="$1"
    local include_docker="$2"
    if [ "$include_docker" = "yes" ]; then
        packages="$packages luci-i18n-dockerman-zh-cn"
    fi
    echo "$packages" | awk '{$1=$1};1'
}

# Check whether a package list includes OpenClash.
# Args: $1=packages string
# Returns 0 if openclash is present, 1 otherwise.
has_openclash() {
    echo "$1" | grep -q "luci-app-openclash"
}

# Check whether a package list includes SSR-Plus.
# Args: $1=packages string
# Returns 0 if ssr-plus is present, 1 otherwise.
has_ssr_plus() {
    echo "$1" | grep -q "luci-app-ssr-plus"
}

# Get the OpenClash meta core URL for the given architecture.
# Args: $1=arch ("amd64"|"arm64")
# Outputs the download URL.
get_openclash_meta_url() {
    local arch="$1"
    echo "https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-${arch}.tar.gz"
}

# Get the mihomo core URL for the given architecture.
# Args: $1=arch ("amd64"|"arm64")  $2=version (default "v1.19.24")
# Outputs the download URL.
get_mihomo_url() {
    local arch="$1"
    local version="${2:-v1.19.24}"
    local compat=""
    if [ "$arch" = "amd64" ]; then
        compat="-compatible"
    fi
    echo "https://github.com/MetaCubeX/mihomo/releases/download/${version}/mihomo-linux-${arch}${compat}-${version}.gz"
}

# Generate the pppoe-settings config file content.
# Args: $1=enable_pppoe  $2=account  $3=password
# Outputs the config file content.
generate_pppoe_config() {
    local enable="$1"
    local account="$2"
    local password="$3"
    cat <<EOF
enable_pppoe=${enable}
pppoe_account=${account}
pppoe_password=${password}
EOF
}

# Merge custom packages into a base package list.
# Args: $1=base packages  $2=custom packages
# Outputs the merged string.
merge_packages() {
    local base="$1"
    local custom="$2"
    echo "$base $custom" | awk '{$1=$1};1'
}

# Determine the package file extension for a given version.
# Args: $1=version ("23"|"24"|"25")
# Outputs "apk" for 25+, "ipk" otherwise.
get_package_extension() {
    local version="$1"
    case "$version" in
        25) echo "apk" ;;
        *)  echo "ipk" ;;
    esac
}

# Determine the third-party store repo URL for a given version.
# Args: $1=version ("23"|"24"|"25")
# Outputs the git clone URL.
get_store_repo_url() {
    local version="$1"
    case "$version" in
        25) echo "https://github.com/wukongdaily/apk.git" ;;
        *)  echo "https://github.com/wukongdaily/store.git" ;;
    esac
}
