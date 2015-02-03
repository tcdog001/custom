#!/bin/sh

get_gateway_version() {                                                         
	gateway_version="`cat ${__CP_WEBSITE__}/ver.info 2>/dev/null`"   
	if [ -z "${gateway_version}" ];then                           
		gateway_version=zj1.2                               
	fi                                                          
#	echo "${gateway_version}"
} 

replace_file() {
	local file_local=$1
	local file_new=$2
	local file_md5=$3
	local md5_local=$(cat "${file_md5}")
	local md5_new=$(md5sum ${file_new} | awk -F ' ' '{print $1}' 2>/dev/null)

	i=0;
	while(( $i < 3 ))
	do

	((i++))
#	echo $i
	


	if [ -e "${file_new}" ];then
		if [ "${md5_local}" != "${md5_new}" ];then
			rm -rf ${file_new} 2>/dev/null
			cp ${file_local} ${file_new} 2>/dev/null
			fsync ${file_new}
			chmod 777 ${file_new}
		fi
	else
		cp ${file_local} ${file_new} 2>/dev/null
		fsync ${file_new}
		chmod 777 ${file_new} 
	fi

	
	done
}

main() {
	local src=/etc/um
	local dst=/data/app/etc/um
	
	if [ ! -d "${dst}" ]; then
		mkdir -p ${dst}
		sync
	fi
	
	replace_file "${src}/usr_certificate.sh" "${dst}/usr_certificate.sh" "${src}/usr_certificate.sh.md5"
}

main "$@"
