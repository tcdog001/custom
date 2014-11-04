#!/bin/bash
#
# call by function
#

. ${__ROOTFS__}/etc/upgrade/upgrade.in

#
# rsync_task.sh is call by
#		rsync_start_bycloud.sh
#		rsync_start_bymanual.sh
#		crond(5 minute)
#		3g_up.system.cb
#
#[$1:json...]
#
main() {
	rsync_rootfs0_check || {
		return ${e_nosupport}
	}

	rsync_with_flock "$*"
}

main "$@"
