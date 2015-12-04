#!/bin/bash

. ${__ROOTFS__}/etc/upgrade/upgrade_boot.in

#
# check the file fastboot-burn.bin and the partition /dev/mmcblk0p1
# if md5sum of fastboot-burn.bin is not equal to md5sum of /dev/mmcblk0p1, do boot upgrade.
#
do_upgrade() {
    local version="$1"
    
    local bootsize=0
    local ret=0
    local ret1=0
    local ret2=0
    local md51=""
    local md52=""

    #md51=$(check_boot_file ${version}; ret1=$?)
    #md52=$(check_bversion_file ${version}; ret2=$?)
    
    if [[ ${ret1} -eq 0 && ${ret2} -eq 0 ]]; then
        if [[ ${md51} = ${md52} ]]; then
        	upgrade_boot "${version}"; ret=$?
		else
			ret=1
        fi
    else
		ret=1
    fi
    
    return ${ret}
}

main() {
    local version="$1"
    local delay="$2"
    
    local ret=0
    local time_delay=0

	[[ ${delay} ]] && time_delay=$(echo ${delay} | grep -Eo '[0-9]+')
	sleep ${time_delay}

	if [[ ${version} ]]; then
		do_upgrade "${version}"; ret=$?
	else
		echo "upgrade_boot.sh [version]"
	fi
	
	return ${ret}
}

main "$@"

