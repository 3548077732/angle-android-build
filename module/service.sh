MODDIR=${0%/*}
Customize(){

#!/system/bin/sh

sleep 8

# 等待 settings 服务就绪（开机早期 settings put 会静默失败）
# 循环探测 settings get 是否可用，最多等 60 秒兜底
SETTINGS_READY=0
_i=0
while [ "$_i" -lt 60 ]; do
    if settings get global angle_gl_driver_selection_pkgs >/dev/null 2>&1; then
        SETTINGS_READY=1
        break
    fi
    _i=$((_i + 1))
    sleep 1
done

# 放开 selinux（仅 Magisk 存在该命令时执行；KernelSU 无 magiskpolicy）
command -v magiskpolicy >/dev/null 2>&1 && magiskpolicy --live "allow * settings_service service_manager find"

# 模板文件 & 用户配置文件 & 运行日志
SRC="$MODDIR/angle.conf.default"
CONF="/data/adb/angle.conf"
LOG="/data/adb/angle.log"

# 日志开关：angle.conf 中 # log_sw=off 时完全关闭日志（不生成任何日志）
LOG_ON=1
LOG_SW=$(sed -n 's/^[[:space:]]*#[[:space:]]*log_sw=//p' "$CONF" 2>/dev/null | tail -1)
if [ "$LOG_SW" = "off" ]; then
    LOG_ON=0
fi
log() {
    [ "$LOG_ON" = 1 ] || return 0
    echo "$(date '+%Y-%m-%d %H:%M:%S') $*" >> "$LOG"
}
if [ "$LOG_ON" = 1 ]; then
    # 日志上限 5MB：超过则删除重建
    if [ -f "$LOG" ]; then
        LOG_SIZE=$(wc -c < "$LOG" 2>/dev/null || echo 0)
        if [ "$LOG_SIZE" -gt 5242880 ]; then
            rm -f "$LOG"
            echo "$(date '+%Y-%m-%d %H:%M:%S') 日志超过 5MB 已清空" >> "$LOG"
        fi
    fi
    chmod 600 "$LOG" 2>/dev/null
    log "service.sh 开始"
fi

# 首次运行：如果用户配置不存在，就从模板复制一份
if [ ! -f "$CONF" ]; then
    if [ -f "$SRC" ]; then
        cp "$SRC" "$CONF"
    else
        cat > "$CONF" <<'EOF'
# 包名 值
com.miui.weather2 native
com.phoenix.read native
com.tencent.nrc native
com.eg.android.AlipayGphone native
EOF
    fi
    chmod 600 "$CONF"
    log "首次运行，已生成默认配置"
fi

sed -i 's/\r$//' "$CONF"

# 确保配置文件以换行结尾（否则最后一行可能被 while read 漏读）
if [ -n "$(tail -c1 "$CONF" 2>/dev/null)" ]; then
    echo >> "$CONF"
fi

# 根据配置文件生成 TARGET_PKGS / TARGET_VALS（过滤注释/空行、校验合法值、去重）
TARGET_PKGS=""
TARGET_VALS=""
SEEN=""
while read -r pkg val; do
    [ -z "$pkg" ] && continue
    case "$pkg" in
        \#*) continue ;;
    esac
    # 校验包名只含字母数字 . _
    case "$pkg" in
        *[!A-Za-z0-9._]*)
            log "跳过非法包名: $pkg"
            continue ;;
    esac
    # 校验取值必须为合法值之一（native/angle/default）
    case "$val" in
        native|angle|default) ;;
        *)
            log "跳过非法取值: $pkg -> $val"
            continue ;;
    esac
    # 去重：重复包名只保留第一条
    case ",$SEEN," in
        *",$pkg,"*)
            log "跳过重复包名: $pkg"
            continue ;;
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

if [ -z "$TARGET_PKGS" ]; then
    # 配置为空：还原系统默认（删除本模块写入的全局设置）
    settings delete global angle_gl_driver_selection_pkgs
    settings delete global angle_gl_driver_selection_values
    log "配置为空，已还原系统默认设置"
    exit 0
fi

# 开机无条件写入配置内容（不做"比对后跳过"：比对 settings 当前值会误判，导致该写不写）
# 日志先记录本次读取到的配置，再写入并回读验证
log "读取配置: $TARGET_PKGS -> $TARGET_VALS"
settings put global angle_gl_driver_selection_pkgs "$TARGET_PKGS"
settings put global angle_gl_driver_selection_values "$TARGET_VALS"
# 回读验证：确认设置真正写入（失败多为 settings 未就绪 / SELinux 拦截）
NEW_PKGS=$(settings get global angle_gl_driver_selection_pkgs)
NEW_VALS=$(settings get global angle_gl_driver_selection_values)
if [ "$NEW_PKGS" = "$TARGET_PKGS" ] && [ "$NEW_VALS" = "$TARGET_VALS" ]; then
    log "已写入设置: $TARGET_PKGS -> $TARGET_VALS（验证通过）"
else
    log "写入失败，设置未生效: 目标=$TARGET_PKGS/$TARGET_VALS 实际=$NEW_PKGS/$NEW_VALS"
fi


}


while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 0.5
done

pm install $MODDIR/system/product/priv-app/ANGLE/ANGLE.apk

settings put global angle_debug_package org.chromium.angle
settings put global angle_gl_driver_all_angle 1


Customize