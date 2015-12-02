#!/bin/sh

exit 0
#. /etc/platform/bin/platform.in

CERTIFICATE=/etc/platform/conf/server.cer
USER_PASSWD=autelanauteviewlms:autelanauteviewlms20140925
URL_PATH=/etc/platform/conf/platform_jlog.json
URL_DEFAULT=https://lms1.autelan.com:8443/LMS/lte/
COOKIE_FILE=/tmp/jlogCookie.txt
PAGE=lteAlarm.do
RESULT_FILE=/tmp/jlogResult.txt
CURLE_OK=0
CURLE_COULDNT_CONNECT=7
CURLE_COULDNT_RESOLVE_HOST=6
RECONNECTION_INTERVAL=5
json_jlog="$*"

if [ -f $RESULT_FILE ];then
	rm $RESULT_FILE
fi

if [ -z "$json_jlog" ];then
	echo "no jlog"
else
	if [ -s $URL_PATH ];then
		url_path=`cat $URL_PATH |jq -j '.url'`
		url=${url_path}${PAGE}
	else
		url=${URL_DEFAULT}${PAGE}
	fi
	
	while true
	do
		curl  -k  -cert $CERTIFICATE  -u $USER_PASSWD  -H "Content-type: application/json"  -X POST  -d "$json_jlog" -s  -c $COOKIE_FILE  $url > $RESULT_FILE
		response=$?
#		if [ $response -eq $CURLE_COULDNT_CONNECT ] || [ $response -eq $CURLE_COULDNT_RESOLVE_HOST ];then
		if [ $response != $CURLE_OK ]; then
			sleep $RECONNECTION_INTERVAL
		else
			break
		fi
	done

	out=`cat $RESULT_FILE |jq '.code'`
	case $out in
		0) 
			echo "push log success!"
			;;
		-1)	
			echo "user/password error!"
			;;
		*) 
			echo "push log fail!"
			;;
	esac

fi

