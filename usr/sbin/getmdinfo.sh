#!/bin/bash

. ${__ROOTFS__}/etc/upgrade/dir.in

HDINFO=/tmp/hdinfo

get_disk_model() {
	#disk_model="`hdparm -I ${dev_hd} | awk -F ':' '/Model Number/{print $2}'| awk -F ' ' '{print $2}' 2>/dev/null`"
	if [ -f ${HDINFO} ];then
		disk_model_temp="`cat ${HDINFO} | awk -F ',' '/Model=/{print $1}' | awk -F '=' '{print $2}'`"
		disk_model="`echo "${disk_model_temp}" | sed 's/[ \t]*$//g'`"
	fi
	if [ -z "${disk_model}" ];then
		disk_model="abcdefg"
	fi
	echo "${disk_model}"
}

get_disk_sn() {
	#disk_sn="`hdparm -I ${dev_hd} | awk -F ':' '/Serial Number/{print $2}'| awk -F ' ' '{print $2}' 2>/dev/null`"
	if [ -f ${HDINFO} ];then
		disk_sn_temp="`cat ${HDINFO} | awk -F ',' '/SerialNo=/{print $3}'| awk -F '=' '{print $2}'`"
		disk_sn="`echo "${disk_sn_temp}" | sed 's/[ \t]*$//g'`"
	fi
	if [ -z "${disk_sn}" ];then
		disk_sn="000000"
	fi
	echo "${disk_sn}"
}

get_gateway_version() {
	gateway_version="`cat ${__CP_WEBSITE__}/ver.info 2>/dev/null`"
	if [ -z "$gateway_version" ];then
		gateway_version=zj1.2
	fi
	echo "$gateway_version"
}

get_content_version() {
	content_version="`cat ${__CP_WEBSITE__}/ver.info 2>/dev/null`"
	if [ -z "$content_version" ];then
		content_version=zj1.2
	fi
	echo "$content_version"
}

get_media_info() {
	hdparm -i ${dev_hd} > ${HDINFO} 2>/dev/null
	local disk_model=$(get_disk_model)
	local disk_sn=$(get_disk_sn)
	local gateway_version=$(get_gateway_version)
	local content_version=$(get_content_version)
	printf '"diskModel":"%s","diskSN":"%s","gateWayVersion":"%s","contentVersion":"%s"\n'   \
		"${disk_model}" \
		"${disk_sn}"	\
		"${gateway_version}"	\
		"${content_version}"
}

main() {
	get_media_info
}

main "$@"
