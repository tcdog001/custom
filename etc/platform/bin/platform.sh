#!/bin/bash

. ${__ROOTFS__}/etc/platform/bin/platform.in

usage() {
	echo "$0 usage:"
	echo "  $0 {action} [config]"
	echo "	  action: command/keepalive/gpslog/syslog"
	echo "	  config: json config file"
	echo
}

#
#$1:action
#[$2:config]
#
main() {
	case $# in
	1|2)
		plt_do "$@" || return $?
		;;
	*)
		usage; return ${e_inval}
	esac
}

main "$@"