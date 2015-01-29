#!/bin/bash

. ${__ROOTFS__}/etc/utils/utils.in

main() {
	local init=/etc/init.d/${__CP__}/init.script
	#
	/usr/localweb/.compare_disk.sh
	sync
	

	#
	#  push du list
	#
	for ((;;)); do
		${init} && break

		sleep 60
	done

}

main "$@"
