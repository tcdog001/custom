#!/bin/bash

. ${__ROOTFS__}/etc/utils/utils.in

#
# atbus.autelan.com ==> 182.254.198.168
#
readonly -A deft_hash=(
	[server]=atbus.autelan.com
	[path]=/opt/version/lte-fi/mdboard
	[port]=873
	[user]=root
	[pass]=ltefi@Autelan1
)

#
# version=xxx server=xxx path=xxx port=xxx user=xxx pass=xxx
#
#
main() {
	local -A hash

	aa_init hash "$@"

	if [[ -z "${hash[version]}" ]]; then
		echo "$0 version=xxx server=xxx path=xxx port=xxx user=xxx pass=xxx"
		echo "		must input version/server/pass"

		return ${e_inval}
	fi

	local key
	for key in ${!deft_hash[@]}; do
		if [[ -z "${hash[${key}]}" ]]; then
			hash[${key}]="${deft_hash[${key}]}"
		fi
	done

	${__ROOTFS__}/etc/upgrade/rsync_task.sh "$(json_from_aa hash)" &
}

main "$@"
