#!/system/bin/sh
# net_helper.sh - Auto route default gateway, DNS, and disable captive portal

# 1. Hardware video decoder permissions & quad-core CPU performance
chmod 0666 /dev/Vcodec 2>/dev/null
echo 1 > /sys/devices/system/cpu/cpufreq/hotplug/is_cpu_hotplug_disable 2>/dev/null
echo 4 > /sys/devices/system/cpu/cpufreq/hotplug/cpu_num_base 2>/dev/null
echo 1 > /sys/devices/system/cpu/cpu1/online 2>/dev/null
echo 1 > /sys/devices/system/cpu/cpu2/online 2>/dev/null
echo 1 > /sys/devices/system/cpu/cpu3/online 2>/dev/null

# Enable 512MB zRAM if not already active
if [ -e /dev/block/zram0 ] && ! grep -q zram /proc/swaps 2>/dev/null; then
    echo 536870912 > /sys/block/zram0/disksize 2>/dev/null
    mkswap /dev/block/zram0 2>/dev/null
    swapon /dev/block/zram0 2>/dev/null
fi

# 2. Disable IPv6 to eliminate phantom DNS timeouts (fe80::1 RDNSS delay)
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6 2>/dev/null
echo 1 > /proc/sys/net/ipv6/conf/wlan0/disable_ipv6 2>/dev/null
echo 1 > /proc/sys/net/ipv6/conf/default/disable_ipv6 2>/dev/null

# 2. Restore time immediately if clock is reset (< 2020)
FLOOR=1577836800 # 2020-01-01
CUR_TIME=$(date +%s 2>/dev/null)
if [ -z "$CUR_TIME" ] || [ "$CUR_TIME" -lt "$FLOOR" ]; then
    BUILD_DATE=$(getprop ro.build.date.utc)
    if [ -n "$BUILD_DATE" ] && [ "$BUILD_DATE" -ge "$FLOOR" ]; then
        date @"$BUILD_DATE" SET 2>/dev/null
    fi
fi

# 3. Disable captive portal, auto-provision, and disable Setup Wizard as soon as framework is ready
(
    while true; do
        if settings get global captive_portal_mode >/dev/null 2>&1; then
            settings put global captive_portal_mode 0 2>/dev/null
            settings put global captive_portal_detection_enabled 0 2>/dev/null
            settings put global captive_portal_server localhost 2>/dev/null
            settings put global ntp_server id.pool.ntp.org 2>/dev/null

            # Permanently provision device and disable setup wizard
            settings put global device_provisioned 1 2>/dev/null
            settings put global setup_wizard_has_run 1 2>/dev/null
            settings put secure user_setup_complete 1 2>/dev/null
            pm disable com.google.android.tungsten.setupwraith 2>/dev/null
            pm disable com.android.provision 2>/dev/null
            break
        fi
        sleep 1
    done
) &

# 4. Force-stop YouTubeTV when returning to Home to avoid MainWebModule resume SIGSEGV
(
    YT_ACTIVE=0
    logcat -b events -T 1 -s am_focused_activity:I | while read -r line; do
        case "$line" in
            *"com.google.android.youtube.tv/"*)
                YT_ACTIVE=1
                ;;
            *"com.mqltv/.MainActivity"*|*"com.google.android.leanbacklauncher"*)
                if [ "$YT_ACTIVE" = "1" ]; then
                    YT_ACTIVE=0
                    am force-stop com.google.android.youtube.tv >/dev/null 2>&1
                fi
                ;;
        esac
    done
) &

# 3. Main network route, DHCP DNS & LAN LED watchdog loop
LAST_NET_LED=""
set_net_led() {
    if [ "$LAST_NET_LED" = "$1" ]; then
        return
    fi
    if [ "$1" = "green" ]; then
        echo off > /proc/ledlight/netred/state 2>/dev/null
        echo on > /proc/ledlight/netgreen/state 2>/dev/null
    else
        echo off > /proc/ledlight/netgreen/state 2>/dev/null
        echo on > /proc/ledlight/netred/state 2>/dev/null
    fi
    LAST_NET_LED="$1"
}

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
            if ! ip rule show 2>/dev/null | grep -q "lookup main"; then
                ip rule add from all lookup main pref 1000 2>/dev/null
            fi
            ip route replace default via "$GW" dev "$IFACE" table main 2>/dev/null

            # Add local subnet to main table
            SUBNET=$(ip route show table all 2>/dev/null | grep -w "$IFACE" | grep -v 'default' | head -n 1 | awk '{print $1}')
            if [ -n "$SUBNET" ]; then
                ip route replace "$SUBNET" dev "$IFACE" table main 2>/dev/null
            fi

            # Use DHCP DNS from router (fallback to gateway) so MikroTik/captive portals resolve
            DNS1=$(getprop dhcp.${IFACE}.dns1)
            DNS2=$(getprop dhcp.${IFACE}.dns2)
            [ -z "$DNS1" ] && DNS1="$GW"
            setprop net.dns1 "$DNS1"
            setprop net.${IFACE}.dns1 "$DNS1"
            if [ -n "$DNS2" ]; then
                setprop net.dns2 "$DNS2"
                setprop net.${IFACE}.dns2 "$DNS2"
            fi
        fi
    fi

    if [ -n "$GW" ] && [ -n "$IFACE" ] && (ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1 || ping -c 1 -W 2 1.1.1.1 >/dev/null 2>&1); then
        set_net_led green
    else
        set_net_led red
    fi
    sleep 3
done
