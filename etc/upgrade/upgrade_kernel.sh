#!/bin/bash

. ${__ROOTFS__}/etc/upgrade/upgrade_kernel.in

do_upgrade() {
    local ret=""

    check_kernel_file ${version}; ret=$?
    if [[ ${ret} -eq 0 ]];then
        compare_uname_time ${version}
    else
	    upgrade_echo_logger "kernel_upgrade" \
        	"version=${version} hi_kernel.bin is not exist"
    fi
}

main() {
    local version=$1
    local upgrade_kernel=$2; shift 2

    if [[ "${upgrade_kernel}" == "yes" ]];then
        do_upgrade
    else
	    upgrade_echo_logger "kernel_upgrade" \
        	"__UPGRADE_KERNEL__=no"
    fi
}

main "$@"

