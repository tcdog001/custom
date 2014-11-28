#!/bin/sh

. /etc/platform/bin/platform.in

CERTIFICATE=/etc/platform/conf/server.cer
USER_PASSWD=autelanauteviewlms:autelanauteviewlms20140925
URL_PATH=/etc/platform/conf/platform.json
URL_DEFAULT=https://atbus.9797168.com:8443/LMS/lte/
COOKIE_FILE=/tmp/commandCookie.txt
PAGE=lteCommand.do
RESULT_FILE=/tmp/commandResult.txt
COMMAND_FILE=/tmp/command.txt
COMMAND_FILE_RE=/tmp/command_record.log
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

	out=`cat $RESULT_FILE |jq -j '.cmd'`
	if [ -f $RESULT_FILE ];then
                rm $RESULT_FILE
        fi
	echo out=$out
	result=`echo "$out" |base64 -d`
	echo $result |tr ";" "\n" > $COMMAND_FILE 
	cat $COMMAND_FILE | while read myCommand
	do
 		echo "Command:"$myCommand
 		echo "Get the Command :"$myCommand";time is :"`date`>> $COMMAND_FILE_RE
		logger "platform" "command:$myCommand"

		eval "$myCommand"
	done
	if [ -f $COMMAND_FILE ];then
		rm $COMMAND_FILE
	fi
else
	logger "platform" "$FILE_REGISTER is not exist!"
fi
