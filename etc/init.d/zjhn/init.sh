#!/bin/bash

. ${__ROOTFS__}/etc/utils/utils.in
. /etc/platform/bin/check_oem_function.in

main() {
	check_oem_lms; err=$?
	if [[ ${err} -eq 0 ]]; then
		/usr/localweb/.compare_disk.sh
		return ${err}
	fi
	
	local init=/etc/init.d/${__CP__}/init.script
	#
	/usr/localweb/.compare_disk.sh
	sync
	
	/etc/um/compare_cp_file.sh
	sync

	#
	#  push du list
	#
	for ((;;)); do
		sleep 60
		${init} && break

	done

}

main "$@"
