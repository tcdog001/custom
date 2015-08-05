#!/bin/bash

change_time_status() {
	local status=$1
	local ip=$2
	local status_file="/tmp/zjhn/userstatus"
	touch "${status_file}"
	
	cat "${status_file}" | grep "${ip} " ;local status_flag=$?
	if [ ${status_flag} -eq 0 ]; then
		sed -i "/${ip} /"d "${status_file}"
	fi
	echo "${ip} ${status}" >> "${status_file}"
}

write_white_list() {
	local mac=$1
	local mac_arp=$(echo "${mac}" | tr '[A-Z]' '[a-z]')
	local status_lock="/tmp/zjhn_status.lock"
	local mac_ipt=$(echo "${mac}" | tr '[a-z]' '[A-Z]')
	
	/sbin/iptables -t mangle -L WiFiDog_eth0.1_Trusted | grep ${mac_ipt} ; local status=$?
	if [ ${status} -ne 0 ]; then
		/sbin/iptables -t mangle -A WiFiDog_eth0.1_Trusted -m mac --mac-source ${mac} -j MARK --set-mark 2
		
		{
		flock -w 10 3 && {
			local ip=$(/sbin/arp | grep "192.168.0." | grep ${mac_arp} | awk -F '(' '{print $2}' | awk -F ')' '{print $1}')
			change_time_status "0" "${ip}"
			}
		} 3<>${status_lock}

	fi
}


main() {
	local mac=$1
	
	write_white_list "${mac}"
}
main "$@"