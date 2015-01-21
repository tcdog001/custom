#!/bin/sh

echo "05_script running!"
export PATH=.:$PATH

if [ -z "$HN_SCRIPT" ]
then
        HN_SCRIPT=/data/zjhn/script
        export HN_SCRIPT
fi

if [ -z "$HN_TMP" ]
then
        HN_TMP=/data/zjhn/tmp
        export HN_TMP
fi

if [ -z "$HN_WEB" ]
then
        HN_WEB=/data/zjhn/www
        export HN_WEB
fi

TASK_INF=99_uptask.ini
FLAG_INF=98_status.ini
REPT_INF=97_report.ini

cd $HN_SCRIPT
if [ -f "$FLAG_INF" ]
then
	rm -rf $FLAG_INF
	touch $FLAG_INF
fi
cat $TASK_INF | grep taskid > $FLAG_INF

VERFILE=ver.info
TASK_ID=`cat $TASK_INF | grep taskid | awk -F "=" '{ print $2 }' | tr -d "\r\n"`
RPTURL=`cat  $TASK_INF | grep rpturl | awk -F "=" '{ print $2 }' | tr -d "\r\n"`

if [ ! -d "$HN_WEB" ]
then
	mkdir -p $HN_WEB
fi

cd $HN_WEB
if [ -f "$VERFILE" ]
then
	rm -rf $VERFILE
	touch $VERFILE
fi

cd $HN_SCRIPT
cat $TASK_INF | grep ver > $HN_WEB/$VERFILE


while [ 1 -eq 1 ]
do
	#Please do not run this statement(line61) for keeping the server taskinfo
	#Otherwise the taskinfo will be removed from database
	#If you wanna re-run the whole script ,please erase the 98_status.ini first and retry from init.sh
	
	echo "finished="`curl -d "taskid=$TASK_ID&action=finished" $RPTURL` > $REPT_INF
	
	SIGNAL=`cat $REPT_INF | grep finished | awk -F "=" '{ print $2 }' | tr -d "\r\n"`
	if [ "$SIGNAL" = "success" ]
	then
		echo  " submit ok "
		break
	fi
	sleep 5m
done

cd $HN_TMP
rm -rf *
cd $HN_SCRIPT
rm -rf $TASK_INF
rm -rf $REPT_INF

echo "DONE!!!!"

exit 0
