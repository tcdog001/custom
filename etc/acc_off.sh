#!/bin/sh

. /etc/platform/bin/platform.in

get_onoff_log() {
	local file_path=/data/opt/log/onoff
	local ontime_file=/data/md-on
	local ontime=$( cat ${ontime_file} |sed -n '$p' )
	local offtime=$(date '+%F-%H:%M:%S')
	local line=$( grep -n "" ${ontime_file} |wc -l )
	local del_line=$(awk 'BEGIN{printf("%d",'$line'-'2')}')

	printf '{"ontime":"%s","offtime":"%s","offreason":"%s"}\n' \
		"${ontime}"  \
		"${offtime}" \
		"ACC-OFF" > ${file_path}/on-off-${offtime}
}
main() {
	/usr/sbin/sysled sata off                                         
	/usr/sbin/sysled sys off                                                  
                                                                          
	kill -9 wget 2>/dev/null                                                  
	kill -9 rsync 2>/dev/null
	
	get_onoff_log
	sync
	sleep 15
	sysreboot
}

main "$@"
