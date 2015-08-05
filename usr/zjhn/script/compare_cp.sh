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
	local src=/usr/${__CP__}/script
	local dst=${__CP_SCRIPT__}
	
	replace_file "${src}/00_set_env.sh" "${dst}/00_set_env.sh" "${src}/00_set_env.sh.md5"
	replace_file "${src}/01_check_update.sh" "${dst}/01_check_update.sh" "${src}/01_check_update.sh.md5"
	replace_file "${src}/02_check_download.sh" "${dst}/02_check_download.sh" "${src}/02_check_download.sh.md5"
	replace_file "${src}/03_check_file.sh" "${dst}/03_check_file.sh" "${src}/03_check_file.sh.md5"
	replace_file "${src}/04_run_update.sh" "${dst}/04_run_update.sh" "${src}/04_run_update.sh.md5"
	replace_file "${src}/05_clean_update.sh" "${dst}/05_clean_update.sh" "${src}/05_clean_update.sh.md5"
	replace_file "${src}/init.sh" "${dst}/init.sh" "${src}/init.sh.md5"
	replace_file "${src}/setup.sh" "${dst}/setup.sh" "${src}/setup.sh.md5"


}

main "$@"
