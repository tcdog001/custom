#!/bin/bash

. ${__ROOTFS__}/etc/fagent/fagent.in

#
#[$1:config]
#
main() {
	fsync_init
}

main "$@"