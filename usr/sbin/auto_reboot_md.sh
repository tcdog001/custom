#!/bin/sh

do_reboot() {
	# Record Timeout log
	local log_path=/opt/log/onoff
	local log_file=timeout-md-on-off-
	local ontime_file=/data/md-on
	local ontime=$(cat ${ontime_file} |sed -n '$p')
	local offtime=$(date '+%F-%H:%M:%S')
	touch /mnt/flash/rootfs_data/acc_off.txt
	echo "{\"ontime\":\"${ontime}\",\"offtime\":\"${offtime}\",\"offreason\":\"timeout\"}" >${log_path}/${log_file}${offtime}

	# close some Process and sync
	/usr/sbin/sysled sata off
	/usr/sbin/sysled sys off
	kill -9 wget 2>/dev/null
	kill -9 rsync 2>/dev/null
	sync
	sleep 10
	echo "*****$(uptime)*****"
	echo "*****timeout now reboot*****"
	sysreboot
}

main() {
	# From power began to wait X hours
	local power_time=$1
	if [[ -z $1 ]];then
		power_time=43200
	fi
	sleep ${power_time};local re=$?
	if [[ ${re} -eq 0 ]];then
		do_reboot
	fi
}

main "$@"
