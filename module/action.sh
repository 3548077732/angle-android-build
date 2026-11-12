MODDIR=${0%/*}

key_click() {
    kc=""
    while [ "$kc" = "" ]; do
        kc="$(getevent -qlc 1 | awk '{ print $3 }' | grep 'KEY_')"
        sleep 0.2
    done
}

echo "是否开启angle（关闭angle需要执行两次）
                   音量↑:开启│音量↓:关闭"
    key_click
    case "$kc" in
        "KEY_VOLUMEUP")
            echo "           ✅"
            echo ""
            settings put global angle_debug_package org.chromium.angle
            settings put global angle_gl_driver_all_angle 1
            echo "-已切开启angle"
            sleep 1
            ;;
        "KEY_VOLUMEDOWN")
            echo "                       ✅"
            echo ""
            settings delete global angle_debug_package
            settings delete global angle_gl_driver_all_angle
            settings delete global angle_gl_driver_selection_pkgs
            settings delete global angle_gl_driver_selection_values
        	echo "-已关闭angle"
            sleep 1
            ;;
    esac    