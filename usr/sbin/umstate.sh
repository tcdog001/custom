#!/bin/bash

. ${__ROOTFS__}/etc/jsock/msg/umevent.in

#
#$1:mac
#$2:ip
#$3:state
#
main() {
	local mac="$1"
	local ip="$2"
	local state="$3"

	sed -i "/${ip}/d" ${file_user_state}
	echo "${ip} ${state}" >> ${file_user_state}
	fsync ${file_user_state}
}

main "$@"
