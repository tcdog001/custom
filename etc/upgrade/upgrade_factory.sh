#!/bin/bash
#
# call by function
#

. ${__ROOTFS__}/etc/upgrade/upgrade.in


#
# Restore factory
#
upgrade_factory_bydd() {
	local version=$1
	local buddy=$(rootfs_buddy)
	local dev=dev_rootfs${buddy}
	local err=0

	upgrade_echo_logger "upgrade_factory" \
		"upgrade_task failed[${err}], try dd if=${dev_rootfs0} of=${!dev}"

	dd if=${dev_rootfs0} of=${!dev}; err=$?
	if ((0!=err)); then
		upgrade_echo_logger "upgrade_factory" \
			"dd buddy failed[${err}], try super recover"

		#
		# then, try upgrade by super recover
		#
		setbootm \
			"rootfs=0" \
			"rootfs1=f" \
			"rootfs2=f" \
			"rootfs1err=0" \
			"rootfs2err=0"
	else
		upgrade_echo_logger "upgrade_factory" \
			"dd to version:${version}"
	fi

	return ${err}
}

#
# Restore factory
#
main() {
	local version=$(get_rootfs_version 0)
	local err=0

	#
	# first, try upgrade by normal
	#
	${__ROOTFS__}/etc/upgrade/upgrade_task.sh ${version}; err=$?
	if ((0!=err)); then
		#
		# upgrade failed, try upgrade by dd
		#
		exec_with_flock ${file_lock_upgrade_task} \
			upgrade_factory_bydd ${version}
	else
		upgrade_echo_logger "upgrade_factory" \
			"rollback to version:${version}"
	fi

	upgrade_echo_logger "upgrade_factory" "system will reboot"
	${__ROOTFS__}/usr/sbin/sysreboot &
}

main "$@"
