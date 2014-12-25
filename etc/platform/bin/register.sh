#!/bin/bash

. ${__ROOTFS__}/etc/platform/bin/platform.in

main() {
	shift

	plt_do init "$@" || return $?
	plt_do register "$@" || return $?
}

main "$@"