#!/bin/bash

. /etc/platform/bin/platform.in

#SYS_LOG_PATH="./asl/"
SYS_LOG="sys_out.log"

SYS_LOG_PATH="/opt/log/sys/md/klog"

SYS_EN="/etc/platform/conf/encrypt_data_sys.dat"
MAC=$(cat ${FILE_REGISTER} | jq -j ".mac" | tr -t ":" "-")
PREFIX="sys-"${MAC}"-"
echo $PREFIX

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
#	echo  $status
#	while true
#	do
#        	if [ !  -f ${SYS_LOG} ];then
#                	sleep 2
#        	else
#                	break
#        	fi       	
#	done
 	if [ $status -eq "200" ];then
              outcontent=$(cat ${SYS_LOG} | jq -j ".success")
              case "$outcontent" in
                      false)
                                echo "${upload} upload error !---time is:"`date` >>error.log
                                ;;
                        true)
				rm ${SYS_LOG_PATH}${upload}
                                echo "${upload} upload success !---time is:"`date`>>error.log
                                ;;
                        *)
                                echo "${upload} unknown status !---time is:"`date`>>error.log
                                ;;
                esac
        else
                 echo "${upload}  upload failed, network have some unknown problems !---time is:"`date`>>error.log
        fi
done
