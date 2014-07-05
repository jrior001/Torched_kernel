#!/sbin/sh
#ramdisk_gov_sed.sh by show-p1984
#Features: 
#extracts ramdisk
#finds busbox in /system or sets default location if it cannot be found
#add init.d support if not already supported
#removes governor overrides
#repacks the ramdisk

mkdir /tmp/ramdisk
cp /tmp/boot.img-ramdisk.gz /tmp/ramdisk/
cd /tmp/ramdisk/
gunzip -c /tmp/ramdisk/boot.img-ramdisk.gz | cpio -i
cd /

#add init.d support if not already supported
found=$(find /tmp/ramdisk/init.rc -type f | xargs grep -oh "run-parts /system/etc/init.d");
if [ "$found" != 'run-parts /system/etc/init.d' ]; then
        #find busybox in /system
        bblocation=$(find /system/ -name 'busybox')
        if [ -n "$bblocation" ] && [ -e "$bblocation" ] ; then
                echo "BUSYBOX FOUND!";
                #strip possible leading '.'
                bblocation=${bblocation#.};
        else
                echo "NO BUSYBOX NOT FOUND! init.d support will not work without busybox!";
                echo "Setting busybox location to /system/xbin/busybox! (install it and init.d will work)";
                #set default location since we couldn't find busybox
                bblocation="/system/xbin/busybox";
        fi
	#append the new lines for this option at the bottom
        echo "" >> /tmp/ramdisk/init.rc
        echo "service userinit $bblocation run-parts /system/etc/init.d" >> /tmp/ramdisk/init.rc
        echo "    oneshot" >> /tmp/ramdisk/init.rc
        echo "    class late_start" >> /tmp/ramdisk/init.rc
        echo "    user root" >> /tmp/ramdisk/init.rc
        echo "    group root" >> /tmp/ramdisk/init.rc
fi

#remove system access to led/currents for bln
found=$(find /tmp/ramdisk/init.qcom.rc -type f | xargs grep -oh "chown system system /sys/class/leds/button-backlight/currents");
if [ "$found" = 'chown system system /sys/class/leds/button-backlight/currents' ]; then

	# reset permissions for button-backlight/currents
	# this will kill CM's variable button brightness
	sed -i -e 's|chown system system /sys/class/leds/button-backlight/currents|chown root root /sys/class/leds/button-backlight/currents|g' /tmp/ramdisk/init.qcom.rc

fi

# make sure all the needed partitions are mounted so they show up in mount
# this may output errors if the partition is already mounted (/data and /cache probably will be), so pipe them to /dev/null
# make sure we mount /system before calling any additional shell scripts,
# because they may use /system/bin/sh instead of /sbin/sh and that may cause problems
mount /system 2> /dev/null
mount /cache 2> /dev/null
mount /data 2> /dev/null

# find out which partitions are formatted as F2FS
mount | grep -q 'data type f2fs'
DATA_F2FS=$?
ui_print "Data f2f result=$DATA_F2FS "
mount | grep -q 'cache type f2fs'
CACHE_F2FS=$?
ui_print "Cache f2f result=$CACHE_F2FS "
mount | grep -q 'system type f2fs'
SYSTEM_F2FS=$?
ui_print "System f2f result=$SYSTEM_F2FS "

if [ $SYSTEM_F2FS -eq 0 ]; then
	$BB sed -i "s/# F2FSSYS//g" /tmp/fstab.qcom.tmp;
else
	$BB sed -i "s/# EXT4SYS//g" /tmp/fstab.qcom.tmp;
fi;

if [ $CACHE_F2FS -eq 0 ]; then
	$BB sed -i "s/# F2FSCAC//g" /tmp/fstab.qcom.tmp;
else
	$BB sed -i "s/# EXT4CAC//g" /tmp/fstab.qcom.tmp;
fi;

if [ $DATA_F2FS -eq 0 ]; then
	$BB sed -i "s/# F2FSDAT//g" /tmp/fstab.qcom.tmp;
else
	$BB sed -i "s/# EXT4DAT//g" /tmp/fstab.qcom.tmp;
fi;

cp /tmp/fstab.qcom.tmp /tmp/fstab.qcom.tmp1;
rm /tmp/ramdisk/fstab.qcom
mv /tmp/fstab.qcom.tmp /tmp/ramdisk/fstab.qcom;

rm /tmp/ramdisk/boot.img-ramdisk.gz
rm /tmp/boot.img-ramdisk.gz
cd /tmp/ramdisk/
find . | cpio -o -H newc | gzip > ../boot.img-ramdisk.gz
cd /

