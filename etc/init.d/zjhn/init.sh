#!/bin/bash

URL_PATH=/etc/platform/conf/platform.json

main() {
	local init=${__CP_SCRIPT__}/init.sh
	local default_url="{\"url\":\"https://atbus.autelan.com:8443/LMS/lte/\"}
	local content_url=$(cat ${URL_PATH})
	
	[[ ${default_url} != ${content_url} ]] && return

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
