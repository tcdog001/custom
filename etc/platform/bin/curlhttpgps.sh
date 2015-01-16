#!/bin/bash

. /etc/platform/bin/platform.in
. /etc/platform/bin/check_oem_function.sh

x=""

GPS_LOG_PATH="/opt/log/gps/"
GPS_LOG="/tmp/gps_out.log"
#TEMP_GPS_LOG_PATH="/opt/log/gps/temp_gps.log"
GPS_EN="/etc/platform/conf/gps_en"

MAC=$(cat ${FILE_REGISTER} | jq -j ".mac" | tr  ":" "-")

i=0
err=0
for file in $(ls ${GPS_LOG_PATH} |grep gps-)
do
        file_name[$i]=$file
        i=`expr $i+1`
done

for upload in ${file_name[*]}
do
	if [ -f ${GPS_LOG} ];then
        	rm ${GPS_LOG}
	fi
        x=$(cat ${GPS_EN})
        gps_data=$(cat ${GPS_LOG_PATH}${upload})

	check_oem_lms; err=$?
	if [[ ${err} = 0 ]]; then
		rm  ${GPS_LOG_PATH}${upload}
		echo "lms changed, cannot send gps to upload1.9797168.com---time is:"`date`>>/tmp/error.log
	else
		status=`curl --max-time 180  -F "type=gps" -F "signature=${x}" -F "ident=${MAC}" -F "content=${gps_data}"  -o  ${GPS_LOG} -s -w  %{http_code}   http://update1.9797168.com:821/wifibox/`
		if [ $status -eq "200" ];then
			outcontent=$(cat ${GPS_LOG} | jq -j ".success")
			if [ ${outcontent} == "false" ];then
				echo "${upload} GPS log upload error !---time is:"`date` >>/tmp/error.log
				break
			elif [ ${outcontent} == "true" ];then
				rm  ${GPS_LOG_PATH}${upload}
				echo "${upload} GPS log upload success !---time is:"`date`>>/tmp/error.log
			else
				echo "${upload} Unknown status !---time is:"`date`>>/tmp/error.log
				break
			fi
		else
			echo "Network have some unknown problems !---time is:"`date`>>/tmp/error.log
			break
		fi
	fi
done

