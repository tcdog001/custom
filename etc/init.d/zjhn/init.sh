#!/bin/bash

. ${__ROOTFS__}/etc/utils/utils.in

main() {
	local init=/etc/init.d/${__CP__}/init.script
	#
	# 1: push du list
	#
	for ((;;)); do
		${init} && break

		sleep 60
	done

	#
	# 2: copy
	#
	if [[ ! -f /mnt/hd/custom/${__CP__}/script/init.sh && \
			-f /usr/${__CP__}/script/init.sh ]]; then
		cp -fpR /usr/${__CP__}/script/* /mnt/hd/custom/${__CP__}/script/
	fi

	#
	# 3: call CP's init
	#
	init=${__CP_SCRIPT__}/init.sh
	if [[ -f "${init}" ]]; then
		${init}
	fi
}

main "$@"
