#!/bin/bash
#
# call by function
#

. ${__ROOTFS__}/etc/upgrade/upgrade.in

#
#$1:version
#
main() {
	local version="$1"

	if [ "1" != "$#" ]; then
		return ${e_inval}
	fi

	upgrade_with_flock "${version}"
}

main "$@"
