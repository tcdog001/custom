#!/bin/bash

. ${__ROOTFS__}/etc/utils/utils.in

cat_file(){

	local file_linke="$1"
	local log_content="$2"
	cat "${file_linke}" | sed -n '1p' | jq -j "${log_content}"

}

umlog_print(){
		
	local link_file="$1"
	
	local user_mac=$(cat_file "${link_file}" '.mac|strings')
	local user_ip=$(cat_file "${link_file}" '.ip|strings')
	local starttime=$(cat_file "${link_file}" '.limit.lan.online.uptime|strings')
	local endtime=$(cat_file "${link_file}" '.limit.lan.online.downtime|strings')
	local user_wifiup=$(cat_file "${link_file}"  '.limit.lan.flow.up.now')
	local user_wifidown=$(cat_file "${link_file}" '.limit.lan.flow.down.now|values')
	local user_3gup=$(cat_file "${link_file}" '.limit.wan.flow.up.now|values')
	local user_3gdown=$(cat_file "${link_file}" '.limit.wan.flow.down.now|values')
	local real_starttime="date -d '${starttime} -0800' -u '+%F-%T'"
	local user_starttime=$(eval ${real_starttime})

	if [[ -z "${endtime}" ]]; then
		local user_endtime=" "
	else 
		local real_endtime="date -d '${endtime} -0800' -u '+%F-%T'"
		local user_endtime=$(eval ${real_endtime})
	fi

	printf '{"mac":"%s","IP":"%s","starttime":"%s","endtime":"%s","wifiup":"%s","wifidown":"%s","3Gup":"%s","3Gdown":"%s"}\n' \
		"${user_mac}"\
		"${user_ip}"\
		"${user_starttime}"\
		"${user_endtime}"\
		"${user_wifiup}"\
		"${user_wifidown}"\
		"${user_3gup}"\
		"${user_3gdown}"
		
}

main(){

	local log_file="/opt/log/flow/user/uv_time_flow-"$(getnow)""
	local file="/tmp/.umc_show.tmp"
	local line_file="/tmp/linefile.log"

	touch "${log_file}"
	umc show > "${file}"
	while read line; do
		echo "${line}" >"${line_file}"
		[[ "${line}" ]] && umlog_print "${line_file}" >> "${log_file}"  
	done < "${file}"
	
}
main "$@"