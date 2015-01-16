#!/bin/bash

. /etc/platform/bin/check_oem_function.sh

main() {
	local err=1
	check_oem_lms; err=$?
	[[ ${err} = 0 ]] && return ${err}

        iptables -t mangle -F WiFiDog_eth0.1_Trusted
}
main "$@"
