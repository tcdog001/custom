#!/bin/bash

. /etc/platform/bin/platform.in
. /etc/utils/utils.in

gps_upload() {

	local GPS_LOG=/tmp/gps_out.log
	local GPS_EN=/etc/platform/conf/gps_en
	local MAC=$(cat ${FILE_REGISTER} | jq -j ".mac" | tr  ":" "-")
	local status info

for upload in $(ls /opt/log/gps/gps-* | sort -r) 
do
	status=$(curl --max-time 180  \
		-F "type=gps" \
		-F "signature=$(cat ${GPS_EN})" \
		-F "ident=${MAC}" \
		-F "content=$(cat ${upload})"  \
		-o  ${GPS_LOG} \
		-s \
		-w  %{http_code}  \
		http://update1.9797168.com:821/wifibox/)
        if [ "$status" -eq "200" ];then
                outcontent=$(cat ${GPS_LOG} | jq -j ".success")
		case ${outcontent} in
		ture)
			info="ok"
			;;
		false)
			info="failed"
			;;
		*)
			info="error"
			;;
		esac
		
		echo "$(getnow) upload ${upload} ${info}" >> ${GPS_LOG}

		rm -f ${upload}
	else
		echo "$(getnow) upload ${upload} status=${status}" >> ${GPS_LOG}
	fi
	
	sleep 1
done
}

main() {
	exec_with_flock	/tmp/.gps_upload.lock gps_upload
}

main "$@"

