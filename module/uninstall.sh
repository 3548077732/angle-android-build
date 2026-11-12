MODDIR=${0%/*}

settings delete global angle_debug_package
settings delete global angle_gl_driver_all_angle
settings delete global angle_gl_driver_selection_pkgs
settings delete global angle_gl_driver_selection_values

sleep 5

settings delete global angle_debug_package
settings delete global angle_gl_driver_all_angle
settings delete global angle_gl_driver_selection_pkgs
settings delete global angle_gl_driver_selection_values


CONF=/data/adb/angle.conf

# 若配置文件存在，解析出模块声明的目标包名/取值（与 service.sh 逻辑一致）
TARGET_PKGS=""
TARGET_VALS=""
SEEN=""
if [ -f "$CONF" ]; then
    while read -r pkg val; do
        [ -z "$pkg" ] && continue
        case "$pkg" in
            \#*) continue ;;
        esac
        # 校验包名只含字母数字 . _
        case "$pkg" in
            *[!A-Za-z0-9._]*) continue ;;
        esac
        # 校验取值必须为合法值之一
        case "$val" in
            native|angle|default) ;;
            *) continue ;;
        esac
        # 去重：重复包名只保留第一条
        case ",$SEEN," in
            *",$pkg,"*) continue ;;
        esac
        SEEN="$SEEN,$pkg"

        if [ -z "$TARGET_PKGS" ]; then
            TARGET_PKGS="$pkg"
            TARGET_VALS="$val"
        else
            TARGET_PKGS="$TARGET_PKGS,$pkg"
            TARGET_VALS="$TARGET_VALS,$val"
        fi
    done < "$CONF"
fi

# 读取系统当前全局设置；settings get 无值时返回 "null"
CUR_PKGS=$(settings get global angle_gl_driver_selection_pkgs)
CUR_VALS=$(settings get global angle_gl_driver_selection_values)

# 仅当系统设置与模块写入的目标一致时才删除，
# 避免误删用户自行设置或其它应用写入的值。
if [ "$CUR_PKGS" = "$TARGET_PKGS" ] && [ "$CUR_VALS" = "$TARGET_VALS" ]; then
    settings delete global angle_gl_driver_selection_pkgs
    settings delete global angle_gl_driver_selection_values
fi

# 删除模块的用户配置文件、运行日志与日志开关标记
rm -rf "$CONF" /data/adb/angle.log


sleep 1

pm uninstall --user 0 org.chromium.angle

rm -rf $MODDIR/*