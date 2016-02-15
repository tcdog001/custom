#!/bin/bash

. ${__ROOTFS__}/etc/upgrade/usbupgrade.in

main() {
	local err=0

	if [ "${__UPGRADE_AP__}" = "no" ]; then
		touch ${file_usbupgrade_noap}
	elif [ "${__UPGRADE_AP__}" = "yes" ]; then
		rm -f ${file_usbupgrade_noap}
	fi

	usbupgrade; err=$?

	return ${err}
}

main
