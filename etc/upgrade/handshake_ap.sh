#!/bin/bash

. ${__ROOTFS__}/etc/upgrade/upgrade_ap.in

main() {
	local err=0

	jsock_md_send_check || {
		return ${e_bad_board}
	}

	handshake_version_with_flock; err=$?

	return ${err}
}

main "$@"
