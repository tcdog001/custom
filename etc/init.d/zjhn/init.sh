#!/bin/bash

. ${__ROOTFS__}/etc/utils/utils.in

main() {
	#
	# 1: copy script
	#
	local src=/usr/${__CP__}/script
	if [[ -f ${src}/init.sh && ! -f ${__CP_SCRIPT__}/init.sh ]]; then
		cp -fpR ${src}/* ${__CP_SCRIPT__}/
		sync
	fi

	#
	# 2: try move website
	#       when old is NOT link and is dir
	#
	local old=/mnt/hd/website
	if [[ ! -h ${old} && -d ${old} ]]; then
		mv ${old}/* ${__CP_WEBSITE__}/
		chmod -R 777 ${__CP_WEBSITE__}
		rm -fr ${old}
		LN_DIR ${dir_cp}/www ${old}
		sync
	fi

	#
	# 3: call CP's init
	#
	local init=${__CP_SCRIPT__}/init.sh
	if [[ -f "${init}" ]]; then
		${init} &
	fi

	#
	# 4: push du list
	#
	for ((;;)); do
		/etc/init.d/${__CP__}/init.script && break

		sleep 60
	done
}

main "$@"
