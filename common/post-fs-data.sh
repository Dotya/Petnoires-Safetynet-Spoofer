#!/system/bin/sh
MODDIR=${0%/*}

exec &> /cache/petnoires-safetyspoofer.log

LOGFILE=/cache/magisk.log

function log_print() {
    echo "$1"
    echo "$1" >> $LOGFILE
    log -p i -t Magisk "$1"
}

set -x
function background() {
  set +x; while :; do
      [ "$(getprop sys.boot_completed)" == "1" ] && {
          set -x; break; }
      sleep 1
  done
}
BBX=/data/adb/magisk/busybox
RESETPROP="resetprop -v -n"

if [ -f "/sbin/resetprop" ]; then RESETPROP="/sbin/$RESETPROP"
elif [ -f "/sbin/magisk" ]; then RESETPROP="/sbin/magisk $RESETPROP"
elif [ -f "/data/magisk/magisk" ]; then RESETPROP="/data/magisk/magisk $RESETPROP"
elif [ -f "/magisk/.core/bin/resetprop" ]; then RESETPROP=/magisk/.core/bin/$RESETPROP
elif [ -f "/data/magisk/resetprop" ]; then RESETPROP=/data/magisk/$RESETPROP; fi


log_print "*** [Universal Hide] Version: $($BBX grep version= $MODDIR/module.prop | $BBX sed 's/version=//')"

[ ! "$(getprop persist.pnss.appendage)" ] && setprop "persist.pnss.appendage" "finger"
APPENDAGE=$(getprop persist.pnss.appendage)

[ "$(getprop persist.pnss.appendage)" == "0" ] || {

  [ "$(getprop persist.pnss.print)" == "0" ] || {
      [ "$(getprop persist.pnss.print)" == "1" ] || [ ! "$(getprop persist.pnss.print)" ] && PRINT=Xiaomi/sagit/sagit:7.1.1/NMF26X/V8.2.17.0.NCACNEC:user/release-keys || PRINT=$(getprop persist.pnss.print)
      log_print "*** [Universal Hide] Changing build ${APPENDAGE}print value"
      $RESETPROP "ro.build.${APPENDAGE}print" "$PRINT"
      $RESETPROP "ro.bootimage.build.${APPENDAGE}print" "$PRINT"
      $RESETPROP "ro.vendor.build.${APPENDAGE}print" "$PRINT"
      if [ $(getprop persist.pnss.appendage) == "finger" ]; then
	      $RESETPROP --delete "ro.build.thumbprint"
	      $RESETPROP --delete "ro.bootimage.build.thumbprint"
        $RESETPROP --delete "ro.vendor.build.thumbprint"
      elif [ $(getprop persist.pnss.appendage) == "thumb" ]; then
        $RESETPROP --delete "ro.build.fingerprint"
        $RESETPROP --delete "ro.bootimage.build.fingerprint"
        $RESETPROP --delete "ro.vendor.build.fingerprint"
      fi
    }
}


log_print "*** [Universal Hide] Hiding dangerous props"

VERIFYBOOT=$(getprop ro.boot.verifiedbootstate)
FLASHLOCKED=$(getprop ro.boot.flash.locked)
VERITYMODE=$(getprop ro.boot.veritymode)
KNOX1=$(getprop ro.boot.warranty_bit)
KNOX2=$(getprop ro.warranty_bit)
DEBUGGABLE=$(getprop ro.debuggable)
SECURE=$(getprop ro.secure)
BUILDTYPE=$(getprop ro.build.type)
BUILDTAGS=$(getprop ro.build.tags)
BUILDSELINUX=$(getprop ro.build.selinux)
RELOADPOLICY=$(getprop selinux.reload_policy)

[ "$VERIFYBOOT" ] && [ "$VERIFYBOOT" != "green" ] && $RESETPROP "ro.boot.verifiedbootstate" "green"
[ "$FLASHLOCKED" ] && [ "$FLASHLOCKED" != "1" ] && $RESETPROP "ro.boot.flash.locked" "1"
[ "$VERITYMODE" ] && [ "$VERITYMODE" != "enforcing" ] && $RESETPROP "ro.boot.veritymode" "enforcing"
[ "$KNOX1" ] && [ "$KNOX1" != "0" ] && $RESETPROP "ro.boot.warranty_bit" "0"
[ "$KNOX2" ] && [ "$KNOX2" != "0" ] && $RESETPROP "ro.warranty_bit" "0"
[ "$DEBUGGABLE" ] && [ "$DEBUGGABLE" != "0" ] && $RESETPROP "ro.debuggable" "0"
[ "$SECURE" ] && [ "$SECURE" != "1" ] && $RESETPROP "ro.secure" "1"
[ "$BUILDTYPE" ] && [ "$BUILDTYPE" != "user" ] && $RESETPROP "ro.build.type" "user"
[ "$BUILDTAGS" ] && [ "$BUILDTAGS" != "release-keys" ] && $RESETPROP "ro.build.tags" "release-keys"
[ "$BUILDSELINUX" ] && [ "$BUILDSELINUX" != "0" ] && $RESETPROP "ro.build.selinux" "0"
[ "$RELOADPOLICY" ] && [ "$RELOADPOLICY" != "1" ] && $RESETPROP "selinux.reload_policy" "1"

background &

exit
