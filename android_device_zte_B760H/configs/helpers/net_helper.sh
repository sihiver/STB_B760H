#!/system/bin/sh
# net_helper.sh - Auto route default gateway and DNS for eth0 & wlan0

# Disable captive portal checks so apps and system don't stall waiting for Google check
settings put global captive_portal_mode 0 2>/dev/null
settings put global captive_portal_detection_enabled 0 2>/dev/null

while true; do
    GW=""
    IFACE=""

    # 1. Try dumpsys connectivity
    ROUTE_LINE=$(dumpsys connectivity 2>/dev/null | grep -o '0\.0\.0\.0/0 -> [0-9.]* [a-zA-Z0-9]*' | head -n 1)
    if [ -n "$ROUTE_LINE" ]; then
        GW=$(echo "$ROUTE_LINE" | sed 's/0.0.0.0\/0 -> //; s/ .*//')
        IFACE=$(echo "$ROUTE_LINE" | sed 's/.* //')
    fi

    # 2. Try ip route show table all
    if [ -z "$GW" ] || [ -z "$IFACE" ]; then
        RT_ALL=$(ip route show table all 2>/dev/null | grep 'default via' | head -n 1)
        if [ -n "$RT_ALL" ]; then
            GW=$(echo "$RT_ALL" | awk '{print $3}')
            IFACE=$(echo "$RT_ALL" | awk '{print $5}')
        fi
    fi

    # 3. Try dhcp properties for eth0 or wlan0
    if [ -z "$GW" ] || [ -z "$IFACE" ]; then
        ETH_GW=$(getprop dhcp.eth0.gateway)
        WLAN_GW=$(getprop dhcp.wlan0.gateway)
        if [ -n "$ETH_GW" ]; then
            GW="$ETH_GW"
            IFACE="eth0"
        elif [ -n "$WLAN_GW" ]; then
            GW="$WLAN_GW"
            IFACE="wlan0"
        fi
    fi

    if [ -n "$GW" ] && [ -n "$IFACE" ]; then
        if ! ip route show table main 2>/dev/null | grep -q "default via $GW dev $IFACE"; then
            ip rule add from all lookup main pref 1000 2>/dev/null
            ip route replace default via "$GW" dev "$IFACE" table main 2>/dev/null

            # Add local subnet to main table
            SUBNET=$(ip route show table all 2>/dev/null | grep -w "$IFACE" | grep -v 'default' | head -n 1 | awk '{print $1}')
            if [ -n "$SUBNET" ]; then
                ip route replace "$SUBNET" dev "$IFACE" table main 2>/dev/null
            fi

            setprop net.dns1 8.8.8.8
            setprop net.dns2 1.1.1.1
            setprop net.${IFACE}.dns1 8.8.8.8
            setprop net.${IFACE}.dns2 1.1.1.1
        fi
    fi
    sleep 3
done
