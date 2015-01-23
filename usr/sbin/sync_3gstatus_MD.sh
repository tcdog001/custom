#!/bin/bash
. /etc/utils/base.in
get_evdo_ip() {
	local evdoip_file=/tmp/.evdo
	local evdo_ip=$(cat ${evdoip_file} |jq -j '.evdo_ip |strings')
	local ap_evdoip_file=/tmp/.ppp/evdo_ip
	local new_evdo_ip=$( /etc/jsock/jcmd.sh syn "cat ${ap_evdoip_file}" 2>/dev/null )

	if [[ ${evdo_ip} != ${new_evdo_ip} ]];then
		 echo "{\"evdo_ip\":\"${new_evdo_ip}\"}" >${evdoip_file}
		/etc/platform/bin/command.sh >/dev/null 2>&1
	fi
}

sync_3gstat() {
	local DOWN=down
	local UP=up
	local status_FILE=/tmp/status/3g_status
	local zjhn_status_FILE=/tmp/zjhn/3gstatus
	local AP_status_file=/tmp/.ppp/status
	local md3gstat=$( cat ${status_FILE} 2>/dev/null )
	local ap3gstat=$( /etc/jsock/jcmd.sh syn "cat ${AP_status_file}" 2>/dev/null )

	if [[ "${ap3gstat}" == "${UP}" ]];then
		get_evdo_ip
	fi

	if [[ -z  "${md3gstat}" ]];then
		echo ${DOWN} >${status_FILE}
	else
		if [[ "${md3gstat}" != "${ap3gstat}" ]];then
			if [[ "${ap3gstat}" == "${UP}" ]];then
				. /etc/jsock/msg/3g_up.system.cb  2>/dev/null
				echo "${UP}" >${status_FILE}
				echo "0" > ${zjhn_status_FILE}
			else
				. /etc/jsock/msg/3g_down.system.cb  2>/dev/null
				echo "${DOWN}" >${status_FILE}
				echo "3" > ${zjhn_status_FILE}
			fi
		fi
	fi
}
readonly sync_3g_lock_file=/tmp/.sync_3gstatus.lock
main() {
	sleep 30
	while :
	do
		exec_with_flock ${sync_3g_lock_file} sync_3gstat
		sleep 10
	done
}

main "$@"
