#!/bin/bash

main() {
	local init=${__CP_SCRIPT__}/init.sh
	if [[ ! -f "${init}" ]]; then
		init=/etc/init.d/${__CP__}/init.script
        fi

	${init} 
}

main "$@"
