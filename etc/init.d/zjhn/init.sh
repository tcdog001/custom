#!/bin/bash

main() {
	local init=${__CP_SCRIPT__}/init.sh

	if [[ ! -f "${init}" ]]; then
		init=/etc/init.d/${__CP__}/init.script
        fi

        local err=0
	for ((;;)); do
		sleep 60
		${init}; err=$?
		if ((0==err)); then
		        return
		fi
        done
}

main "$@"
