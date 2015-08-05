#!/bin/bash

. ${__ROOTFS__}/etc/upgrade/usbupgrade.in

main() {
	local err=0

	usbupgrade; err=$?

	return ${err}
}

main
