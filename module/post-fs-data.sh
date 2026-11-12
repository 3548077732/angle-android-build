#!/system/bin/sh
# 请不要硬编码 /magisk/modname/... ; 请使用 $MODDIR/...
#MODDIR=${0%/*}
#MNT="/" #从根目录挂载（默认从/mnt/vendor/挂载）
# 这将使你的脚本更加兼容，即使Magisk在未来改变了它的挂载点
MODDIR=${0%/*}

bind_mount(){
    source="${2:-$MODDIR/$1}"
    chmod --reference "$1" "$source"
    chown --reference "$1" "$source"
    chcon --reference "$1" "$source"
    mount --bind "$source" "$1"
}

sleep 0.5

bind_mount "/system/vendor/etc/permissions/android.hardware.vulkan.level-1.xml"
bind_mount "/system/vendor/etc/permissions/android.hardware.opengles.aep.xml"
bind_mount "/system/vendor/etc/permissions/android.hardware.vulkan.compute-0.xml"
bind_mount "/system/vendor/etc/permissions/android.software.vulkan.deqp.level.xml"
bind_mount "/system/vendor/etc/permissions/android.hardware.vulkan.version-1_4.xml"
bind_mount "/system/vendor/etc/permissions/android.hardware.vulkan.version-1_3.xml"
bind_mount "/system/vendor/etc/permissions/android.hardware.vulkan.version-1_1.xml"

exit 0