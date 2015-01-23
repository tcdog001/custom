#!/bin/bash

write_time_status() {
	local ARP_FLIE="/tmp/arp.log"
	local ZJHN_USERSTATUES="/tmp/zjhn/userstatus"
	
	cat /dev/null > "${ZJHN_USERSTATUES}"
	
	/sbin/arp | grep "eth0.1" | grep "192.168.0." > "${ARP_FLIE}"
	cat "${ARP_FLIE}" | while read line
		do
			local ip=$(echo "$line" | awk -F '(' '{print $2}' | awk -F ')' '{print $1}')
			if [ -z ${ip} ]; then
				echo "no ip"
			else
				echo "${ip} 2" >> "${ZJHN_USERSTATUES}"
			fi
		done
}


main() {
	local status_lock="/tmp/zjhn_status.lock"

    iptables -t mangle -F WiFiDog_eth0.1_Trusted

	{
		flock -w 10 3 && {
			write_time_status
			}
	} 3<>${status_lock}
}
main "$@"