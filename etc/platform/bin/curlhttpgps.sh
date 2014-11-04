#!/bin/bash

. /etc/platform/bin/platform.in

x=""

GPS_LOG_PATH="/opt/log/gps/"
GPS_LOG="/tmp/gps_out.log"
TEMP_GPS_LOG_PATH="/opt/log/gps/temp_gps.log"

GPS_EN="/etc/platform/conf/gps_en"

MAC=$(cat ${FILE_REGISTER} | jq -j ".mac" | tr -t ":" "-")

echo $MAC

if [ -f ${GPS_LOG} ];then
        rm ${GPS_LOG}
fi

i=0
for file in $(ls ${GPS_LOG_PATH} |grep gps-)
do
        file_name[$i]=$file
        i=`expr $i+1`
done

for upload in ${file_name[*]}
do
	cat ${GPS_LOG_PATH}${upload} >> ${TEMP_GPS_LOG_PATH}
	rm  ${GPS_LOG_PATH}${upload}
done

if [ -f $TEMP_GPS_LOG_PATH ];then
	x=$(cat ${GPS_EN})
	gps_data=$(cat $TEMP_GPS_LOG_PATH)
	status=`curl --max-time 180  -F "type=gps" -F "signature=${x}" -F "ident=${MAC}" -F "content=${gps_data}"  -o  ${GPS_LOG} -s -w  %{http_code}   http://update1.9797168.com:821/wifibox/`
#	while true
#	do
#       	if [ ! -f ${GPS_LOG} ];then
#                	sleep 2
#        	else
#                	break
#        	fi
#	done
	if [ $status -eq "200" ];then
		outcontent=$(cat ${GPS_LOG} | jq -j ".success")
        	echo out=$outcontent
        	case "$outcontent" in
                	false)
                        	echo "GPS log upload error !---time is:"`date` >>/tmp/error.log
                        	;;
                	true)
                        	rm $TEMP_GPS_LOG_PATH
				echo "GPS log upload success !---time is:"`date`>>/tmp/error.log
                        	;;
                	*)
                        	echo "Unknown status !---time is:"`date`>>/tmp/error.log
                        	;;
        	esac

	else
		 echo "Network have some unknown problems !---time is:"`date`>>/tmp/error.log
	fi
else
        echo "file do not exit!--time is:"`date` >>/tmp/error.log 
fi

