#!/bin/sh

get_gateway_version() {                                                         
	gateway_version="`cat /mnt/hd/website/ver.info 2>/dev/null`"   
	if [ -z "${gateway_version}" ];then                           
		gateway_version=zj1.2                               
	fi                                                          
#	echo "${gateway_version}"
} 

replace_file() {
	local PATH_HD=/mnt/hd/website
	local PATH_FILE=/usr/localweb
	
	local index0925=`cat /usr/localweb/.index.md5sum`
	local nochkCode0925=`cat /usr/localweb/.nochkCode.md5sum`
	local logSec0925=`cat /usr/localweb/.logSec.md5sum`

	local indexnew=`md5sum /mnt/hd/website/index.html |awk -F ' ' '{print $1}' 2>/dev/null`
	local nochkCodenew=`md5sum /mnt/hd/website/nochkCode.php |awk -F ' ' '{print $1}' 2>/dev/null`
	local logSecnew=`md5sum /mnt/hd/website/logSec.html |awk -F ' ' '{print $1}' 2>/dev/null`

	i=0;
	while(( $i < 3 ))
	do

	((i++))
#	echo $i
	
	if [ -e ${PATH_HD}/index.html ];then
		if [ ${index0925} != ${indexnew} ];then
			rm -rf ${PATH_HD}/index.html 2>/dev/null
			cp ${PATH_FILE}/.index.html ${PATH_HD}/index.html 2>/dev/null
			fsync ${PATH_HD}/index.html
			chmod 777 ${PATH_HD}/index.html
		fi
	else
		cp ${PATH_FILE}/.index.html ${PATH_HD}/index.html 2>/dev/null
		fsync ${PATH_HD}/index.html
		chmod 777 ${PATH_HD}/index.html 
	fi

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

	if [ -e ${PATH_HD}/logSec.html ];then
		if [ ${logSec0925} != ${logSecnew} ];then
			rm -rf ${PATH_HD}/logSec.html 2>/dev/null
			cp ${PATH_FILE}/.logSec.html ${PATH_HD}/logSec.html 2>/dev/null
			fsync ${PATH_HD}/logSec.html
			chmod 777 ${PATH_HD}/logSec.html
		fi
	else
		cp ${PATH_FILE}/.logSec.html ${PATH_HD}/logSec.html 2>/dev/null    
		fsync ${PATH_HD}/logSec.html
		chmod 777 ${PATH_HD}/logSec.html 
	fi
	
	done
}

main() {
	get_gateway_version
	
	if [ "${gateway_version}" == "zj1.2" ];then
		replace_file
	fi
}

main "$@"
