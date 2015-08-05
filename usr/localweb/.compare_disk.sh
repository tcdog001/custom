#!/bin/sh

get_gateway_version() {                                                         
	gateway_version="`cat ${__CP_WEBSITE__}/ver.info 2>/dev/null`"   
	if [ -z "${gateway_version}" ];then                           
		gateway_version=zj1.2                               
	fi                                                          
#	echo "${gateway_version}"
} 

replace_file() {
	local PATH_HD=${__CP_WEBSITE__}
	local PATH_FILE=/usr/localweb
	
	local nochkCode0925=`cat /usr/localweb/.nochkCode.md5sum`

	local nochkCodenew=`md5sum ${PATH_HD}/nochkCode.php |awk -F ' ' '{print $1}' 2>/dev/null`

	i=0;
	while(( $i < 3 ))
	do

	((i++))
#	echo $i
	


	if [ -e ${PATH_HD}/nochkCode.php ];then
		if [ ${nochkCode0925} != ${nochkCodenew} ];then
			rm -rf ${PATH_HD}/nochkCode.php 2>/dev/null
			cp ${PATH_FILE}/.nochkCode.php ${PATH_HD}/nochkCode.php 2>/dev/null
			fsync ${PATH_HD}/nochkCode.php
			chmod 777 ${PATH_HD}/nochkCode.php
		fi
	else
		cp ${PATH_FILE}/.nochkCode.php ${PATH_HD}/nochkCode.php 2>/dev/null
		fsync ${PATH_HD}/nochkCode.php
		chmod 777 ${PATH_HD}/nochkCode.php 
	fi

	
	done
}

main() {

		replace_file

}

main "$@"
