#!/bin/bash

. /etc/platform/bin/syslog.in

main() {
	local err=0
	local mac=$(get_mac) || return $?

	local signature=$(cat /etc/platform/conf/encrypt_data_sys.dat)
	local output=/tmp/syslog.out

	local file
	for file in $(ls ${dir_backup_log}/sys-* | sort -r); do
		local newname=$(basename ${file})
		newname=${newname#sys-}
		newname=${newname//:/-}

		local status=$(curl -s \
					--max-time 180 \
					-F "type=sys" \
					-F "signature=${signature}" \
					-F "ident=${mac}" \
					-F "content=@${file};filename=${newname};type=text/plain" \
					-o ${output} \
					-w  %{http_code} \
					http://update1.9797168.com:821/wifibox/); err=$?
		if [ "${status}" != "200" ]; then
			echo_logger "platform" \
				"ERROR[${err}]: upload ${file} failed"
			return ${err}
		elif [ "true" != "$(cat ${output} | jq -j '.success|booleans')" ]; then
			echo_logger "platform" \
				"upload ${file} failed"
			return 1
		fi

		rm -f ${file} > /dev/null 2>&1
	done
}

main "$@"

