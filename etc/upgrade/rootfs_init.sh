#!/bin/bash

. ${__ROOTFS__}/etc/upgrade/upgrade.in

main() {
#	${__ROOTFS__}/usr/sbin/resetd &
	${__ROOTFS__}/etc/platform/bin/register.sh &
	${__ROOTFS__}/etc/upgrade/websiteupgrade.sh &

#	${__ROOTFS__}/usr/sbin/monitord &
#	${__ROOTFS__}/usr/sbin/monitors &

	rootfs_init
}

main "$@"
