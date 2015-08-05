#!/bin/sh

get_onoff_log() {
	local ontime=$( cat /data/md-on |sed -n '$p' )
	local offtime=$(cat /data/md-off)
	local file_path=/data/opt/log/onoff
	local line=$( grep -n "" /data/md-on |wc -l )
	local del_line=$(awk 'BEGIN{printf("%d",'$line'-'2')}')

	if [[ $line -gt 2 ]];then
		sed -e "1,${del_line}"d /data/md-on -i 2>/dev/null
	fi

	if [[ -e /data/acc_off.txt ]];then
		rm -rf /data/acc_off.txt;                             
		return 0;
	else
		echo "{\"ontime\":\"${ontime}\",\"offtime\":\"${offtime}\",\"offreason\":\"DROP-OFF\"}" >${file_path}/on-off-${offtime}
	fi
}

main() {
	get_onoff_log
}

main "$@"
