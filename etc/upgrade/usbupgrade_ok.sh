#!/bin/bash

. ${__ROOTFS__}/etc/upgrade/usbupgrade.in

main() {
	usbupgrade_ok
}

main
