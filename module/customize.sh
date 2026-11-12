SKIPUNZIP=0
MIUI=$(getprop ro.vendor.build.version.incremental)
Manufacturer=$(getprop ro.product.vendor.brand)
Codename=$(getprop ro.product.vendor.device)
Model=$(getprop ro.product.vendor.model)
Build=$(getprop ro.build.version.incremental)
AndroidVersion=$(getprop ro.build.version.release)
CPU_ABI=$(getprop ro.vendor.product.cpu.abilist)
HyperOS=$(getprop ro.vendor.build.version.incremental)
VERSION=$(getprop ro.build.version.release)
API=$(getprop ro.product.first_api_level)

	ui_print "- Magisk version: $MAGISK_VER_CODE"
	ui_print "- Module version: $(grep_prop version "$MODPATH/module.prop")"
	ui_print "- Module versionCode: $(grep_prop versionCode "$MODPATH/module.prop")"
	ui_print "**************************************************"
	ui_print "- $(grep_prop description "$MODPATH/module.prop")"
	ui_print "**************************************************"
	ui_print "- KernelSU 用户空间版本号: $KSU_VER_CODE"
  ui_print "- KernelSU 内核空间版本号: $KSU_KERNEL_VER_CODE"
  version="$KSU_VER_CODE"
  versionCode="$KSU_KERNEL_VER_CODE"
  ui_print "- APatch 版本名: $APATCH_VER"
  ui_print "- APatch 版本号: $APATCH_VER_CODE"
  version="$APATCH_VER"
  versionCode="$APATCH_VER_CODE"
  ui_print "- Magisk 版本名: $MAGISK_VER"
  ui_print "- Magisk 版本号: $MAGISK_VER_CODE"
  version="$MAGISK_VER"
  versionCode="$MAGISK_VER_CODE"
  
  unzip -o "$ZIPFILE" 'system.prop' -d $MODPATH >&2
  
  unzip -o "$ZIPFILE" 'system/*' -d $MODPATH >&2
  
  unzip -o "$ZIPFILE" 'service.sh' -d $MODPATH >&2
  
  unzip -o "$ZIPFILE" 'action.sh' -d $MODPATH >&2
  
  unzip -o "$ZIPFILE" 'post-fs-data.sh' -d $MODPATH >&2
  
  unzip -o "$ZIPFILE" 'uninstall.sh' -d $MODPATH >&2
  
  unzip -o "$ZIPFILE" 'webroot/*' -d $MODPATH >&2
  
  unzip -o "$ZIPFILE" 'angle.conf.default' -d $MODPATH >&2
  
set_permissions() {
 set_perm_recursive $MODPATH 0 0 0755 0755 
 set_perm_recursive "$MODPATH/system/lib*/*.so" 0 0 0755 0644 
#设置权限，基本不要去动
}
set_permissions
