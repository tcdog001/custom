#!/bin/sh

. /etc/platform/bin/platform.in

/usr/sbin/sysled sata off
/usr/sbin/sysled sys off

kill -9 wget 2>/dev/null
kill -9 rsync 2>/dev/null

MAC=$(cat $FILE_REGISTER |awk -F ',' '{print $4}' |awk -F '"' '{print $4}' |sed 's/:/-/g') 2>/dev/null
if [ ! -z $MAC ];then
	echo $MAC >/mnt/flash/rootfs_data/ap_mac
fi

line=` grep -n "" /data/startime |wc -l `
line2=$(awk 'BEGIN{printf("%d",'$line'-'2')}')
if [ $line -gt 2 ];then
	sed -e "1,$line2"d /data/startime -i 2>/dev/null
fi

dmac=`cat /data/ap_mac`
startime=` cat /data/startime |sed -n '$p' `
offtime=`date`
echo "{\"dmac\":\"$dmac\",\"startime\":\"$startime\",\"offtime:\"$offtime\",\"sign\":\"ACC-OFF\"}" >/opt/log/sys/md/power_off.log

sync

sleep 15
sysreboot
