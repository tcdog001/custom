#!/bin/bash

. ${__ROOTFS__}/etc/upgrade/upgrade_kernel.in

#
# check the file /etc/.kversion and hi_kernel.bin
# if the two files are exist, compare the time
#
do_upgrade() {
    local version=$1
    local ret_k=""
    local ret_kv=""

    check_kernel_file ${version}; ret_k=$?
    check_kversion_file ${version}; ret_kv=$?
    if [[ ${ret_k} -eq 0 && ${ret_kv} -eq 0 ]];then
        compare_uname_time ${version}
    else
        return 1
    fi
}

main() {
    local version=$1

    do_upgrade ${version}
}

main "$@"

