#!/bin/bash

. ${__ROOTFS__}/etc/upgrade/usbupgrade.in

#
# sys  led is on
# sata led is blink
#
main() {
	usbupgrade_blink_one sata on
}

main
