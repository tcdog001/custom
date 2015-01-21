#!/bin/sh

echo "01_script running!"
export PATH=.:$PATH
if [ -z $HN_SCRIPT ]
then
	HN_SCRIPT=/data/zjhn/script
	export HN_SCRIPT
fi

#*********** Get Device MAC Address **********
if [ -n "${__CP_DEVMAC__}" ]; then
	MACADDR=$(echo ${__CP_DEVMAC__} | tr -d "-")
else
	MAC_01=`ifconfig |grep em1  | awk '{ print $5 }' | head -1`
	MAC_02=`ifconfig |grep eth0 | awk '{ print $5 }' | head -1`

	if [ -n "$MAC_01" ]
	then
		MAC=$MAC_01
	elif [ -n "$MAC_02" ]
	then
		MAC=$MAC_02
	else
		echo "error"
		exit 0;
	fi
	MACADDR=`echo $MAC | tr -d ':'`
fi

#PLEASE ERASE THIS MACADDR SETTING STATEMENT
#MACADDR=C81F66BCE9D9

#********** Request Task Info From IDC **********
TASK_INF=99_uptask.ini
FLAG_INF=98_status.ini

cd $HN_SCRIPT
rm -rf $TASK_INF


# ********** Get Taskinfo from Server and Save into 99_uptask.ini until get Correct info **********
# none is no task.  taskid=xxx means there is a task. 
# others means server contacted error and need retry
 
while [ 1 -eq 1 ]
do
	curl -d mac=$MACADDR http://data.9797168.com:8080/update/get_new_ver > $TASK_INF
	CONT_ID=`cat $TASK_INF | tr -d "\r\n"`
	TASK_ID=`cat $TASK_INF | grep taskid | awk -F "=" '{ print $2 }' | tr -d "\r\n"`
	if [ "$CONT_ID" = "none" ]
	then	
		echo  "none task"
		exit 0
	elif [ -n "$TASK_ID" ]
	then
		break
	fi
	sleep 5m
done

#********** Local parse and Process ***********
ntid=`cat $TASK_INF | grep taskid | awk -F "=" '{ print $2 }' | tr -d "\r\n"`

if [ -z "$ntid" ]
then
	exit 0;
else
	02_check_download.sh
fi

#otid=`cat $FLAG_INF | grep taskid | awk -F "=" '{ print $2 }' | tr -d "\r\n"`

exit 0
