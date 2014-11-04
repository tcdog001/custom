#!/bin/bash

. ${__ROOTFS__}/etc/utils/utils.in

#
#$1:json
#
main() {
	local json="$*"

	json_check "${json}" || {
		echo "$0 json"

		return ${e_inval}
	}

	${__ROOTFS__}/etc/upgrade/rsync_task.sh "${json}" &

}

main "$@"
