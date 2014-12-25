#!/bin/bash

. ${__ROOTFS__}/etc/upgrade/usbupgrade.in

#
# sys  led is off
# sata led is blink
#
main() {
	usbupgrade_blink_one sata off
}

main
