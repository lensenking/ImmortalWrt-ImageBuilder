#!/bin/sh
# Extracted helper functions from files/etc/uci-defaults/99-custom.sh
# These functions encapsulate testable network configuration logic.

# Detect physical network interfaces (eth*/en*) from /sys/class/net.
# Outputs a space-separated list of interface names.
detect_interfaces() {
    local sysnet="${1:-/sys/class/net}"
    local ifnames=""
    for iface in "$sysnet"/*; do
        iface_name=$(basename "$iface")
        if [ -e "$iface/device" ] && echo "$iface_name" | grep -Eq '^eth|^en'; then
            ifnames="$ifnames $iface_name"
        fi
    done
    echo "$ifnames" | awk '{$1=$1};1'
}

# Map board name to WAN/LAN interface assignments.
# Args: $1=board_name  $2=space-separated interface list
# Outputs two lines: first is wan_ifname, second is lan_ifnames.
map_interfaces() {
    local board_name="$1"
    local ifnames="$2"

    case "$board_name" in
        "radxa,e20c"|"friendlyarm,nanopi-r5c")
            echo "eth1"
            echo "eth0"
            ;;
        *)
            echo "$ifnames" | awk '{print $1}'
            echo "$ifnames" | cut -d ' ' -f2-
            ;;
    esac
}

# Determine the network mode based on interface count.
# Args: $1=interface count
# Outputs: "single", "multi", or "none"
get_network_mode() {
    local count="$1"
    if [ "$count" -eq 1 ] 2>/dev/null; then
        echo "single"
    elif [ "$count" -gt 1 ] 2>/dev/null; then
        echo "multi"
    else
        echo "none"
    fi
}

# Read a custom router IP from a file, falling back to default.
# Args: $1=path to IP file
# Outputs the IP address to use.
get_router_ip() {
    local ip_file="$1"
    if [ -f "$ip_file" ]; then
        cat "$ip_file"
    else
        echo "192.168.100.1"
    fi
}

# Determine whether PPPoE should be enabled.
# Args: $1=enable_pppoe value
# Returns 0 (true) if enabled, 1 (false) otherwise.
is_pppoe_enabled() {
    [ "$1" = "yes" ]
}

# Validate PPPoE credentials.
# Args: $1=account  $2=password
# Returns 0 if both are non-empty, 1 otherwise.
validate_pppoe_credentials() {
    local account="$1"
    local password="$2"
    [ -n "$account" ] && [ -n "$password" ]
}

# Parse the pppoe-settings file and output key=value pairs.
# Args: $1=path to settings file
# Returns 0 and outputs contents if file exists, 1 otherwise.
parse_pppoe_settings() {
    local settings_file="$1"
    if [ -f "$settings_file" ]; then
        cat "$settings_file"
        return 0
    else
        return 1
    fi
}
