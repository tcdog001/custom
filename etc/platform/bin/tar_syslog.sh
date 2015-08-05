#!/bin/bash

. /etc/platform/bin/syslog.in

main() {
	local err=0
	local mac=$(get_mac) || return $?

	create_file "$(get_filename ${mac})"
}

main "$@"

