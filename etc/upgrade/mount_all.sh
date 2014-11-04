#!/bin/bash

. ${__ROOTFS__}/etc/upgrade/dir.in

main() {
	mount_all
	setup_dir
}

main "$@"
