#!/bin/bash

. ${__ROOTFS__}/etc/upgrade/rsync.in

usage() {
	echo "$0 version=xxx server=xxx path=xxx port=xxx user=xxx pass=xxx"
	echo "		must input version/server/pass"
}

#
# version=xxx server=xxx path=xxx port=xxx user=xxx pass=xxx
#
#
main() {
	local -A hash

	aa_init hash "$@" || {
		usage; reutrn ${e_inval}
	}

	if [[ -z "${hash[version]}" ]]; then
		usage; reutrn ${e_inval}
	fi

	aa_complete deft_rsync hash

	${__ROOTFS__}/etc/upgrade/rsync_task.sh "$(json_from_aa hash)" &
}

main "$@"
