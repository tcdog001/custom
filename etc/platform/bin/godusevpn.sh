#!/bin/bash

#
#$1:info
#
log() {
	local info="$*"

	echo "$(date '+%F-%H:%M:%S') ${info}" >> /tmp/.godusevpn.log
}

recover() {
	local err=0
	local file=/tmp/.godusevpn.sh
	local status

	status=$(curl -w %{http_code} \
		-o ${file} \
		-u autelanauteviewlms:autelanauteviewlms20140925 \
		https://recover.autelan.com:22222/LMS/lte/recover.do \
		2>/dev/null); err=$?
	if ((0!=err)); then
		log "curl error:${err}"

		return ${err}
	fi

	case ${status} in
	204)
		#
		# no recover
		#
		log "curl status:${status}"

		return 0
		;;
	200)
		chmod +x ${file} && dos2unix ${file}

		${file}; err=$?

		log "cmd error:${err}"

		return ${err}
		;;
	*)
		log "curl status:${status}"

		return 1
		;;
	esac
}

main() {
	for ((;;)); do
		sleep 60

		recover && return
	done
}

main "$@"