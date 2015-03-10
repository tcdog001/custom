#!/bin/bash
	
. ${__ROOTFS__}/etc/jsock/jsock.in

#
# call by busybox udhcpd
#
#$1:event
#$2:mac
#$3:ip
#[$4:class]
#
main() {
	jsock_md_send_check || {
		return ${e_bad_board}
	}

	local event="$1"
	local mac="$2"
	local ip="$3"
	local class="$4"

	local json=$(json_create_bykvs \
					event "${event}" \
					mac "${mac}" \
					ip "${ip}")
	if [[ "auth" == "${event}" && -n "${class}" ]]; then
		json=$(json_add "${json}" class "${class}")
	fi

	${__ROOTFS__}/etc/jsock/jmsg.sh syn umnotify "${json}"
}

main "$@"
