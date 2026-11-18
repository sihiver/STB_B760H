#!/system/bin/sh

while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 2
done

HOME_PKG=$(cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME | tail -n 1 | cut -d/ -f1)
PREV_PKG=""

logcat -b events -T 1 -v raw am_focused_activity:I *:S | while IFS= read -r line; do
    case "$line" in
        \[*,*/*)
            CUR_PKG=${line#*,}
            CUR_PKG=${CUR_PKG%%/*}
            ;;
        *)
            continue
            ;;
    esac

    if [ -z "$HOME_PKG" ] || [ "$HOME_PKG" = "android" ]; then
        HOME_PKG=$(cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME | tail -n 1 | cut -d/ -f1)
    fi

    if [ "$CUR_PKG" = "$HOME_PKG" ] && [ -n "$PREV_PKG" ] && [ "$PREV_PKG" != "$HOME_PKG" ]; then
        case "$PREV_PKG" in
            android|com.android.systemui|com.android.packageinstaller|com.android.tv.launcher|com.google.android.tvlauncher|com.google.android.leanbacklauncher|com.cyanogenmod.trebuchet)
                ;;
            *)
                sleep 0.3
                am force-stop "$PREV_PKG"
                ;;
        esac
    fi

    PREV_PKG="$CUR_PKG"
done

