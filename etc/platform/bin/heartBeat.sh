#!/bin/sh

. /etc/platform/bin/platform.in

CERTIFICATE=/etc/platform/conf/server.cer
USER_PASSWD=autelanauteviewlms:autelanauteviewlms20140925
URL_PATH=/etc/platform/conf/platform.json
URL_DEFAULT=https://atbus.9797168.com:8443/LMS/lte/
COOKIE_FILE=heartBeatCookie.txt
PAGE=lteHeartBeat.do
RESULT_FILE=heartBeatResult.txt
if [ -f $RESULT_FILE ];then
	rm $RESULT_FILE
fi
if [ -f $FILE_REGISTER ];then
	if [ -s $URL_PATH ];then
		url_path=`cat $URL_PATH |jq -j '.url'`
		url=${url_path}${PAGE}
	else
		url=${URL_DEFAULT}${PAGE}
	fi
	echo url=$url

	macKey='{"mac":'
	macValue=`cat $FILE_REGISTER |jq '.mac'`
	endChar='}'
	mac=${macKey}${macValue}${endChar}
	echo mac=$mac

	curl  -k  -cert $CERTIFICATE  -u $USER_PASSWD  -H "Content-type: application/json"  -X POST  -d $mac  -s  -c $COOKIE_FILE  $url > $RESULT_FILE

	out=`cat $RESULT_FILE |jq '.code'`
	echo out=$out
	case $out in
		0) 
			echo "device is online!"
			;;
		-1)	
			echo "user/password error!"
			;;
		*) 
			echo "device is offline!"
			;;
	esac
	if [ -f $RESULT_FILE ];then
		rm $RESULT_FILE
	fi
else
	echo $FILE_REGISTER" is not exist!"
fi
