#!/bin/bash
source shell/custom-packages.sh
source shell/switch_repository.sh
source shell/build-common.sh
echo "第三方软件包: $CUSTOM_PACKAGES"
# yml 传入的路由器型号 PROFILE
echo "Building for profile: $PROFILE"
echo "Include Docker: $INCLUDE_DOCKER"
# yml 传入的固件大小 ROOTFS_PARTSIZE
echo "Building for ROOTFS_PARTSIZE: $ROOTSIZE"
if [ -z "$CUSTOM_PACKAGES" ]; then
  echo "⚪️ 未选择 任何第三方软件包"
else
  # 下载 run 文件仓库
  sync_third_party_packages "https://github.com/wukongdaily/store.git" "/tmp/store-run-repo" "arm64" "ipk"
fi


LUCI_VERSION="${LUCI_VERSION:-24.10.4}"  # workflow 传入的luci版本，默认为24.10.4
# 根据 PROFILE 选择 CPU_ARCH
case "$PROFILE" in
  rpi-3)
    CPU_ARCH="aarch64_cortex-a53"
    ;;
  rpi-4)
    CPU_ARCH="aarch64_cortex-a72"
    ;;
  rpi-5)
    CPU_ARCH="aarch64_cortex-a76"
    ;;
  *)
    CPU_ARCH="aarch64_generic"
    ;;
esac

# 插入架构优先级
sed -i "1i\
arch aarch64_generic 10\n\
arch $CPU_ARCH 15" repositories.conf

# 修改树莓派 repositories.conf 仓库路径，使通用包使用 aarch64_generic，并动态填 LUCI_VERSION
sed -i -E "s|(src/gz immortalwrt_base .*aarch64_cortex-a[0-9]+)/base|src/gz immortalwrt_base https://downloads.immortalwrt.org/releases/$LUCI_VERSION/packages/aarch64_generic/base|" repositories.conf
sed -i -E "s|(src/gz immortalwrt_luci .*aarch64_cortex-a[0-9]+)/luci|src/gz immortalwrt_luci https://downloads.immortalwrt.org/releases/$LUCI_VERSION/packages/aarch64_generic/luci|" repositories.conf
sed -i -E "s|(src/gz immortalwrt_packages .*aarch64_cortex-a[0-9]+)/packages|src/gz immortalwrt_packages https://downloads.immortalwrt.org/releases/$LUCI_VERSION/packages/aarch64_generic/packages|" repositories.conf
sed -i -E "s|(src/gz immortalwrt_routing .*aarch64_cortex-a[0-9]+)/routing|src/gz immortalwrt_routing https://downloads.immortalwrt.org/releases/$LUCI_VERSION/packages/aarch64_generic/routing|" repositories.conf
sed -i -E "s|(src/gz immortalwrt_telephony .*aarch64_cortex-a[0-9]+)/telephony|src/gz immortalwrt_telephony https://downloads.immortalwrt.org/releases/$LUCI_VERSION/packages/aarch64_generic/telephony|" repositories.conf
echo "✅ repositories.conf updated for $PROFILE with generic fallback and LUCI_VERSION=$LUCI_VERSION"
echo "Current repositories.conf content:"
cat repositories.conf
# 输出调试信息
echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting build process..."


# 定义所需安装的包列表
PACKAGES=""
PACKAGES="$PACKAGES curl"
PACKAGES="$PACKAGES luci-i18n-firewall-zh-cn"
# 服务——FileBrowser 用户名admin 密码admin
PACKAGES="$PACKAGES luci-i18n-filebrowser-go-zh-cn"
PACKAGES="$PACKAGES luci-theme-argon"
PACKAGES="$PACKAGES luci-app-argon-config"
PACKAGES="$PACKAGES luci-i18n-argon-config-zh-cn"
PACKAGES="$PACKAGES luci-i18n-diskman-zh-cn"

#24.10
PACKAGES="$PACKAGES luci-i18n-package-manager-zh-cn"
PACKAGES="$PACKAGES luci-i18n-ttyd-zh-cn"
PACKAGES="$PACKAGES openssh-sftp-server"
# ======== shell/custom-packages.sh =======
# 合并imm仓库以外的第三方插件
PACKAGES="$PACKAGES $CUSTOM_PACKAGES"

add_docker_package
setup_openclash_core "arm64"
download_openclash_client "ipk"
setup_mihomo_core "arm64"

build_image PROFILE=$PROFILE PACKAGES="$PACKAGES" FILES="/home/build/immortalwrt/files" ROOTFS_PARTSIZE=$ROOTSIZE
