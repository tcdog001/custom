#!/bin/bash

. ${__ROOTFS__}/etc/upgrade/dir.in

main() {
	umount_all
}

main "$@"
