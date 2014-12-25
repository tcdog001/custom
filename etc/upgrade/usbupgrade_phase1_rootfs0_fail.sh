#!/bin/bash

. ${__ROOTFS__}/etc/upgrade/usbupgrade.in

#
# sys  led is blink
# sata led is off
#
main() {
	usbupgrade_blink_one sys off
}

main
