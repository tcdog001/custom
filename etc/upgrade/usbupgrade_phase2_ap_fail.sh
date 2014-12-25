#!/bin/bash

. ${__ROOTFS__}/etc/upgrade/usbupgrade.in

#
# sys  led is blink
# sata led is on
#
main() {
	usbupgrade_blink_one sys on
}

main
