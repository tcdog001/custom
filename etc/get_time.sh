#!/bin/sh       

. /etc/platform/bin/platform.in

offtime_file=/mnt/flash/rootfs_data/md-off
ontime_file=/mnt/flash/rootfs_data/md-on
apmac_file=/mnt/flash/rootfs_data/ap-mac

get_ontime() {
	export TZ=UTC-8
	date '+%F-%H:%M:%S' >>${ontime_file} 2>/dev/null
	sleep 5
	date '+%F-%H:%M:%S' >${offtime_file} 2>/dev/null
}

get_apmac() {
	local MAC=$(cat ${FILE_REGISTER} |jq -j '.mac' |strings) 2>/dev/null
	if [[ ! -z ${MAC} ]];then
		echo $MAC >${apmac_file}
	else
		sleep 60
		local MAC=$(cat ${FILE_REGISTER} |jq -j '.mac' |strings) 2>/dev/null
		date '+%F-%H:%M:%S' >${offtime_file} 2>/dev/null
		if [[ ! -z ${MAC} ]];then
                	echo $MAC >${apmac_file}
		else
			sleep 30
			local arpMAC=$(arp 1.0.0.1 |awk -F ' ' '{print $4}' |sed 's/:/-/g')
			if [[ ! -z ${arpMAC} ]];then
				echo ${arpMAC} >${apmac_file}
			fi
		fi
	fi
}

get_offtime() { 
	while :
	do
		date '+%F-%H:%M:%S' >${offtime_file} 2>/dev/null
		sleep 60
	done
}

main() {
	get_ontime
	get_apmac
	get_offtime
}

main "$@"

