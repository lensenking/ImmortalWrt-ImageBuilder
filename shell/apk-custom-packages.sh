#!/bin/bash
# ============================================================================
# N100 定制插件清单 · ImmortalWrt 25.12 (apk)
# 用途: 替换 fork 来的 wukongdaily/ImmortalWrt-ImageBuilder 仓库里的
#       shell/apk-custom-packages.sh, 然后跑 "build 25.12.x ISO" 工作流。
# 原理: 每行就是往 $CUSTOM_PACKAGES 追加包名;
#       luci-i18n-X-zh-cn 会自动带出对应的 luci-app-X 和后端程序。
# ============================================================================

CUSTOM_PACKAGES=""

# ------------------- 代理全家桶 (全装上, 默认都不启用, 刷完只开 1 个!) -------------------
# OpenClash (mihomo 内核由 build25.sh 自动下载, UI 本身就是中文)
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-openclash"
# PassWall (含 xray-core / sing-box / hysteria 核心)
CUSTOM_PACKAGES="$CUSTOM_PACKAGES xray-core sing-box hysteria luci-i18n-passwall-zh-cn"
# clashoo (kenzok8 · mihomo/sing-box)
CUSTOM_PACKAGES="$CUSTOM_PACKAGES clashoo luci-app-clashoo luci-i18n-clashoo-zh-cn"
# Nikki (mihomo 透明代理)
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-nikki-zh-cn"
# dae / daed (eBPF 透明代理, 依赖内核 BTF —— ImmortalWrt 默认已开)
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-daed-zh-cn"

# ------------------- DNS -------------------
# mosdns (DNS 分流转发)
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-mosdns-zh-cn"

# ------------------- 网络加速 / 全锥NAT / 软件卸载 / BBR -------------------
# TurboACC: 软件卸载(offload) + 全锥形NAT + BBR 一站式开关。
# (firewall4 / eBPF-BTF / fullcone 这些内核能力 ImmortalWrt 25.12 本身已自带)
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-turboacc-zh-cn"

# ------------------- 多线负载 / 网络服务 / 系统工具 -------------------
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-mwan3-zh-cn"      # mwan3 多线负载
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-sqm-zh-cn"        # SQM 智能队列
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-upnp-zh-cn"       # UPnP (你确认的 upup)
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-ddns-zh-cn"       # DDNS 动态域名
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-netdata-zh-cn"    # netdata 实时监控
CUSTOM_PACKAGES="$CUSTOM_PACKAGES htop"                       # htop
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-base-zh-cn"       # 全中文基础包
# (ttyd / apk图形装包 / firewall 中文 已在 build25.sh 的基础清单里, 无需重复)

# ------------------- 主题: kucat (Argon 已默认带) -------------------
# ⚠️ kucat 是第三方主题, 是本清单里最可能"找不到包"的一项。
#    若构建日志报 unable to select package luci-theme-kucat,
#    就把下面这一行改回注释(行首加 #)再重新 Run, 刷机后用"应用商店"在线装即可。
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-theme-kucat luci-app-kucat-config luci-i18n-kucat-config-zh-cn"

export CUSTOM_PACKAGES
