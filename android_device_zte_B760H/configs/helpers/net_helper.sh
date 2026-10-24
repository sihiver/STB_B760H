#!/system/bin/sh
# net_helper.sh - Auto route default gateway for wlan0 & eth0 on any network
while true; do
    ROUTE_LINE=$(dumpsys connectivity 2>/dev/null | grep -o '0\.0\.0\.0/0 -> [0-9.]* [a-zA-Z0-9]*' | head -n 1)
    if [ -n "$ROUTE_LINE" ]; then
        GW=$(echo "$ROUTE_LINE" | sed 's/0.0.0.0\/0 -> //; s/ .*//')
        IFACE=$(echo "$ROUTE_LINE" | sed 's/.* //')
        if [ -n "$GW" ] && [ -n "$IFACE" ]; then
            if ! ip route show table main 2>/dev/null | grep -q "default via $GW dev $IFACE"; then
                ip rule add from all lookup main pref 1000 2>/dev/null
                ip route replace default via "$GW" dev "$IFACE" table main
                setprop net.dns1 8.8.8.8
                setprop net.dns2 1.1.1.1
            fi
        fi
    fi
    sleep 3
done
