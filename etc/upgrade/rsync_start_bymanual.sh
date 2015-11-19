#!/bin/bash


#
# version=xxx server=xxx path=xxx port=xxx user=xxx pass=xxx
#
#
main() {
	local args=" $*"
	local -A hash
	local json

	#
	# " version=xxx server=xxx path=xxx port=xxx user=xxx pass=xxx"
	#	==>
	# " [version=xxx [server=xxx [path=xxx [port=xxx [user=xxx [pass=xxx"
	#
	args=${args// / [}
	#
	# " [version=xxx [server=xxx [path=xxx [port=xxx [user=xxx [pass=xxx"
	#	==>
	# " [version]=xxx [server]=xxx [path]=xxx [port]=xxx [user]=xxx [pass]=xxx"
	#
	args=${args//=/]=}
	eval "hash=(${args})"

	if [ -z "${hash[version]}" ]; then
		echo "$0 version=xxx server=xxx path=xxx port=xxx user=xxx pass=xxx"
		echo "		must input version/server/pass"

		return ${e_inval}
	fi
	json="\"version\":\"${hash[version]}\""

	#
	# atbus.autelan.com ==> 182.254.198.168
	#
	if [ -z "${hash[server]}" ]; then
		hash[server]="atbus.autelan.com"
	fi
	json="${json},\"server\":\"${hash[server]}\""

	if [ -z "${hash[path]}" ]; then
		hash[path]="/opt/version/lte-fi/mdboard"
	fi
	json="${json},\"path\":\"${hash[path]}\""

	if [ -z "${hash[port]}" ]; then
		hash[port]="873"
	fi
	json="${json},\"port\":\"${hash[port]}\""

	if [ -z "${hash[user]}" ]; then
		hash[user]="root"
	fi
	json="${json},\"user\":\"${hash[user]}\""

	if [ -z "${hash[pass]}" ]; then
		hash[pass]="ltefi@Autelan1"
	fi
	json="${json},\"pass\":\"${hash[pass]}\""

	if [ "${__UPGRADE_KERNEL__}" = "no" ]; then
		upgrade_kernel="no"	
	else
		upgrade_kernel="yes"
	fi
	json="${json},\"upgrade_kernel\":\"${upgrade_kernel}\""

	if [ "${__UPGRADE_BOOT__}" = "yes" ]; then
		upgrade_boot="yes"	
	else
		upgrade_boot="no"
	fi
	json="${json},\"upgrade_boot\":\"${upgrade_boot}\""

	json="{${json}}"
	${__ROOTFS__}/etc/upgrade/rsync_task.sh "${json}" &
}

main "$@"
