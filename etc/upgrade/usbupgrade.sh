#!/bin/bash

. ${__ROOTFS__}/etc/upgrade/usbupgrade.in

main() {
	usbupgrade || return $?
}

main
