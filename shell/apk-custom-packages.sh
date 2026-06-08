#!/bin/bash
# ============================================================================
# N100 定制插件清单 · ImmortalWrt 25.12 (apk) · 第2版
# 已剔除该预编译源里"不存在"的包(kucat/mosdns/turboacc-i18n)与冲突包(nikki)。
# 其余均经 25.12 ImageBuilder 解析器验证可用。
# ============================================================================

CUSTOM_PACKAGES=""

# ------------------- 代理 (全装上, 默认不启用, 刷完只开 1 个!) -------------------
# OpenClash (mihomo 内核由 build25.sh 自动下载, UI 本身中文)
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-app-openclash"
# PassWall (含 xray-core / sing-box / hysteria 核心)
CUSTOM_PACKAGES="$CUSTOM_PACKAGES xray-core sing-box hysteria luci-i18n-passwall-zh-cn"
# clashoo (kenzok8 · mihomo/sing-box)  —— 与 nikki 互斥, 二者只能留一个, 保留 clashoo
CUSTOM_PACKAGES="$CUSTOM_PACKAGES clashoo luci-app-clashoo luci-i18n-clashoo-zh-cn"
# dae / daed (eBPF 透明代理, 依赖内核 BTF —— ImmortalWrt 默认已开)
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-daed-zh-cn"

# ------------------- 多线负载 / 网络服务 / 系统工具 -------------------
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-mwan3-zh-cn"      # mwan3 多线负载
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-sqm-zh-cn"        # SQM 智能队列
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-upnp-zh-cn"       # UPnP (upup)
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-ddns-zh-cn"       # DDNS
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-netdata-zh-cn"    # netdata 监控
CUSTOM_PACKAGES="$CUSTOM_PACKAGES htop"                       # htop
CUSTOM_PACKAGES="$CUSTOM_PACKAGES luci-i18n-base-zh-cn"       # 全中文基础

# 注: 图形应用商店 luci-app-store 经实测在此预编译源里无现成 apk(no such package), 已移除;
#     在线装/升级插件请用系统自带的 apk「软件包」页(官方源)。

# ------------------- BBR -------------------
# BBR 由 files/etc/sysctl.d/99-bbr.conf 启用 (x86 内核已内建 bbr, 无需额外 kmod 包)

# (ttyd / apk图形装包 / firewall 中文 / argon 主题 已在 build25.sh 基础清单, 无需重复)
# 注: eBPF-BTF / 全锥形NAT / 软件卸载(offload) / firewall4 均为 ImmortalWrt 25.12 内核与系统自带,
#     进后台 网络→防火墙 可开"软件流量分载", 全锥NAT 默认即生效。

export CUSTOM_PACKAGES
