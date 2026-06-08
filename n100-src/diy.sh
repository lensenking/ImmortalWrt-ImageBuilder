#!/bin/bash
# ============================================================================
# N100 · ImmortalWrt 25.12 源码编译 · 自定义脚本
# 运行位置: immortalwrt 源码根目录;时机: clone 之后、feeds update 之前。
# ============================================================================
set -e

echo "[diy] 1) 追加第三方 feed"
# kenzok8 大杂烩源: openclash / passwall / clashoo / daed / mosdns 等
sed -i '$a src-git smpackage https://github.com/kenzok8/small-package' feeds.conf.default
# turboacc: 软件卸载 + 全锥NAT + BBR 一站式 (分支 luci, 含 luci-app-turboacc)
sed -i '$a src-git turboacc https://github.com/chenmozhijin/turboacc;luci' feeds.conf.default
# gSpotx2f: 系统监控小部件 (温度/网络检测/CPU状态/磁盘信息)
sed -i '$a src-git gspotx2f https://github.com/gSpotx2f/packages-openwrt;master' feeds.conf.default

echo "[diy] 2) kucat 主题 (单包仓库 → 放进 package/)"
rm -rf package/luci-theme-kucat
git clone --depth=1 https://github.com/sirpdboy/luci-theme-kucat package/luci-theme-kucat

echo "[diy] 3) 用 dnsmasq-full 替换精简版 (代理/mosdns 需要; ImmortalWrt 多数已默认)"
sed -i 's/\bdnsmasq\b/dnsmasq-full/g' include/target.mk 2>/dev/null || true

echo "[diy] feeds.conf.default 末尾:"
tail -4 feeds.conf.default
echo "[diy] done"
