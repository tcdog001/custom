#!/bin/bash

URL_PATH=/etc/platform/conf/platform.json

check_oem_lms() {
	local default_url="{\"url\":\"https://atbus.autelan.com:8443/LMS/lte/\"}"
	local content_url=$(cat ${URL_PATH})

	[[ ${default_url} != ${content_url} ]] && return 0
	return 1
}

redo_register() {
	killall register.sh
	/etc/platform/bin/register.sh &
}
#
# $@: lms which is read from ap board
#
set_md_lms() {
	local lms="$@"
	local lms_url="{\"url\":\"https://${lms}:8443/LMS/lte/\"}"
	local default_url="{\"url\":\"https://atbus.autelan.com:8443/LMS/lte/\"}"
	local content_url=$(cat ${URL_PATH})
	local operation=1
	
	if [[ -z ${lms} && ${default_url} != ${content_url} ]]; then
		echo "${default_url}" > ${URL_PATH}
	elif [[ ${lms} && ${lms_url} != ${content_url} ]]; then
		echo "${lms_url}" > ${URL_PATH}
	else
		operation=0
	fi
	
	[[ ${operation} = 1 ]] && redo_register
}
#
# $@: portal which is read from ap board
#
set_md_portal() {
	local portal="$@"
	local get_portal="address=/${portal}/192.168.0.1"
	local default_portal="address=/9797168.com/192.168.0.1"
	local final_portal=""
	local dnsmasq_file=/etc/dnsmasq.conf
	local dnsmasq_file_tmp=/tmp/dnsmasq.tmp
	local dnsmasq_file_tmp_tmp=/tmp/dnsmasq.tmp.tmp	
	sed -n '/\/192.168.0.1/p' ${dnsmasq_file} > ${dnsmasq_file_tmp}
	sed -ni '/^address=/p' ${dnsmasq_file_tmp}
	awk -F '/' '{print $2}' ${dnsmasq_file_tmp} > ${dnsmasq_file_tmp_tmp}
	
	local line=0
	local operation=0
	local str_tmp=""

	while read str_tmp; do
		#echo "read from ${dnsmasq_file_tmp}:${line}: ${str_tmp}"
		if [[ -z ${portal} && ${str_tmp} != ${default_portal} ]]; then
			final_portal=${default_portal}
			operation=1
		elif [[ ${portal} && ${str_tmp} != ${get_portal} ]]; then
			final_portal=${get_portal}
			operation=1
		fi
		((line++))
	done < ${dnsmasq_file_tmp}

	str_tmp=""
	if [[ ${operation} = 1 ]]; then
		while read str_tmp; do
			# do use eval!!
			eval sed -i '/${str_tmp}/d' ${dnsmasq_file}
		done < ${dnsmasq_file_tmp_tmp}
		echo "${final_portal}" >> ${dnsmasq_file}
		killall dnsmasq 2>/dev/null
		/bin/dnsmasq & 2>/dev/null
	fi
	rm ${dnsmasq_file_tmp_tmp} ${dnsmasq_file_tmp}
}

