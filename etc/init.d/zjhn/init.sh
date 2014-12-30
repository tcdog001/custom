#!/bin/bash

main() {
	local init=${__CP_SCRIPT__}/init.sh
	if [[ ! -f "${init}" ]]; then
		init=/etc/init.d/${__CP__}/init.script
        fi

        local err=0
	for ((;;)); do
		${init}; err=$?
		if ((0==err)); then
		        return
		fi
		sleep 60
        done
}

main "$@"
