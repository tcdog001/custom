#!/bin/bash

. /etc/platform/bin/platform.in
. /etc/upgrade/dir.in 

declare -A logs
declare -A functions
readonly dir_temp=/tmp/.platform_syslog

#
#$1:dir
#[$2:limit, KB]
#
log_limit() {
	local dir="$1"
	local limit="$2"; limit=${limit:=4096}

	local files=$(ls ${dir}/startup-* 2>/dev/null | sort -r)
	local size=$(du -c ${files} | grep total | awk '{print $1}')
	local file
	while ((size>limit)); do
		file=$(get_list_first ${files})
		rm -f ${file}

		files=$(get_list_tail ${files})
		if [ -z "${files}" ]; then
			return
		fi

		size=$(du -c ${files} | grep total | awk '{print $1}')
	done
}

get_startup() {
	cat /tmp/.startup
}

get_startup_file() {
	echo "startup-$(get_startup)"
}

#
#$1:dir
#$2:log
#
get_private_log() {
	local dir="$1"
	local log="$2"

	#
	# get file list by prefix
	#
	local prefix=$(getfilename ${log})
	local files=$(ls ${dir}/${prefix}-* 2>/dev/null | sort -r)
	if [ -z "${files}" ]; then
		return
	fi

	#
	# save to startup files
	#
	local file
	local startup=${dir}/$(get_startup_file)
	for file in ${files}; do
		cat ${file} >> ${startup}; fsync ${startup}
	done

	#
	# copy new to temp
	#
	local old=$(get_list_first ${files})
	local new=${dir_temp}/${log}
	cp -f ${old} ${new}; fsync ${new}

	#
	# delete file list
	#
	rm -f ${files}; sync

	log_limit ${dir}

	logs[${log}]=${new}
}

#
#$1:dir
#$2:log
#$3:daemonlog
#
get_daemon_log() {
	local dir="$1"
	local log="$2"
	local daemonlog="$3"

	local old=${dir}/${daemonlog}
	local new=${dir_temp}/${log}
	local startup=${dir}/$(get_startup_file)

	cp -f ${old} ${new}; >${old}; fsync ${new}
	cat ${new} >> ${startup}; fsync ${startup}

	log_limit ${dir} 8192

	logs[${log}]=${new}
}

get_device_info() {
	do_nothing
}
#functions[device.info]=get_device_info

get_car_system_log() {
	get_private_log ${dir_opt_log_dev_monitor} car_system.log
}
functions[car_system.log]=get_car_system_log

get_vcc_quality_log() {
	get_private_log ${dir_opt_log_vcc} vcc-quality.log
}
functions[vcc-quality.log]=get_vcc_quality_log

get_wifi_drop_log() {
	get_private_log ${dir_opt_log_drop_wifi} wifi-drop.log
}
#functions[wifi-drop.log]=get_wifi_drop_log

get_3g_drop_log() {
	get_private_log ${dir_opt_log_drop_3g} 3g-drop.log
}
#functions[3g-drop.log]=get_3g_drop_log

get_gps_drop_log() {
        get_private_log ${dir_opt_log_drop_gps} gps-drop.log
}
#functions[gps-drop.log]=get_gps_drop_log

get_3g_flow_log() {
	get_private_log ${dir_opt_log_flow_3g} 3g-flow.log
}
functions[3g-flow.log]=get_3g_flow_log

get_onoff_log() {
	do_nothing
}
#functions[on-off.log]=get_onoff_log

get_flow_user_log() {
	get_private_log ${dir_opt_log_flow_user} uv_time_flow.log	
}
functions[uv_time_flow.log]=get_flow_user_log

get_squid_access_log() {
	get_daemon_log ${dir_opt_log_squid_access} squid_access.log squid.log
}
#functions[squid_access.log]=get_squid_access_log

get_pv_http_log() {
	get_daemon_log ${dir_opt_log_nginx_access} pv_http.log nginx.log
	sed -i '/wifidog/d' ${logs[pv_http.log]}
}
functions[pv_http.log]=get_pv_http_log

get_content_update_log() {
	do_nothing
}
#functions[content_update.log]=get_content_update_log

get_software_update_log() {
	do_nothing
}
#functions[software_update.log]=get_software_update_log

#
#$1:file
#
create_file() {
	local file="$1"
	mkdir -p ${dir_temp}

	#
	# prepare files
	#
	local func
	for func in ${functions[*]}; do
		${func}
	done

	#
	# tar
	#
	pushd ${dir_temp} > /dev/null 2>&1
	rm -f ${file} > /dev/null 2>&1
	tar -zcvf ${file} ${!logs[*]} >/dev/null 2>&1; fsync ${file}
	popd > /dev/null 2>&1

	rm -f ${logs[*]} > /dev/null 2>&1
}

get_mac() {
	local mac=$(cat ${FILE_REGISTER} | jq -j '.mac|strings' | tr  ":" "-")

	if [[ -z "${mac}" ]]; then
		return 1
	fi

	echo "${mac}"
}

#
#$1:mac
#
get_filename() {
	local mac="$1"

	echo "${dir_backup_log}/sys-${mac}-$(getnow).tar.gz"
}

main() {
	local err=0
	local mac=$(get_mac) || return $?

	create_file "$(get_filename ${mac})"

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

