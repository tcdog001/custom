#!/bin/bash

. /etc/platform/bin/platform.in
. /etc/upgrade/dir.in 

SYS_LOG="/tmp/sys_out.log"
SYS_LOG_PATH=${BACKUP_LOG}
PV_HTTP_PATH=${dir_opt_log_nginx_access}"/nginx.log"
TEMP_PV_HTTP_PATH=${dir_opt_log_nginx_access}"/pv_http.log"


SYS_EN="/etc/platform/conf/encrypt_data_sys.dat"
MAC=$(cat ${FILE_REGISTER} | jq -j ".mac" | tr  ":" "-")
PREFIX="sys-"${MAC}"-"

tar_name=${PREFIX}`date "+%g-%m-%d-%H-%M-%S"`".tar.gz"
if [ -f ${PV_HTTP_PATH} ];then
        cat ${PV_HTTP_PATH} >> ${TEMP_PV_HTTP_PATH}
        echo "" >${PV_HTTP_PATH}
        tar -zcvf  ${SYS_LOG_PATH}${tar_name} ${TEMP_PV_HTTP_PATH}
        rm ${TEMP_PV_HTTP_PATH}
fi
                                

i=0
for file in $(ls ${SYS_LOG_PATH})
do
	file_name[$i]=$file
	i=`expr $i+1`
done

for upload in ${file_name[*]}
do
	x=''
	if [ -f ${SYS_LOG} ];then
		rm ${SYS_LOG}
	fi
	x=$(cat ${SYS_EN})
	status=`curl --max-time 180  -F "type=sys" -F "signature=${x}" -F "ident=${MAC}" -F "content=@${SYS_LOG_PATH}${upload};type=text/plain" -o ${SYS_LOG} -s -w  %{http_code}   http://update1.9797168.com:821/wifibox/`
 	if [ $status -eq "200" ];then
              outcontent=$(cat ${SYS_LOG} | jq -j ".success")
              if [ ${outcontent} == "false" ];then
                      echo "${upload} upload error !---time is:"`date` >>/tmp/sys_error.log
              elif [ ${outcontent} == "true" ];then
			rm ${SYS_LOG_PATH}${upload}
                        echo "${upload} upload success !---time is:"`date`>>/tmp/sys_error.log
	      else
                      echo "${upload} unknown status !---time is:"`date`>>/tmp/sys_error.log
              fi 
        else
                 echo "${upload}  upload failed, network have some unknown problems !---time is:"`date`>>/tmp/sys_error.log
        	 break
        fi
done

