#!/bin/sh

echo "03_script running!"
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

TASK_INF=99_uptask.ini
FLAG_INF=98_status.ini
REPT_INF=97_report.ini

cd $HN_SCRIPT
# ********** Get File Name and Size and MD5 Info **********
if [ ! -e "$TASK_INF" ]
then
	01_check_update.sh
fi

PKGNAME=`cat $TASK_INF | grep pkgname | awk -F "=" '{ print $2 }' | tr -d "\r\n"`
PKG_MD5=`cat $TASK_INF | grep md5     | awk -F "=" '{ print $2 }' | tr -d "\r\n" | tr '[a-z]' '[A-Z]'`
PKGSIZE=`cat $TASK_INF | grep size    | awk -F "=" '{ print $2 }' | tr -d "\r\n"`

# ********** Get Download File Size and MD5 Info **********
if [ -d "$HN_TMP" ]
then
	cd $HN_TMP
else
	mkdir -p $HN_TMP
	cd $HN_TMP
fi

if [ -e "$PKGNAME" ]
then
	DOWN_MD5=`md5sum $PKGNAME | awk -F " " '{ print $1 }' | tr -d "\r\n" | tr '[a-z]' '[A-Z]'`
	#DOWNSIZE=`du -sb $PKGNAME | awk        '{ print $1 }'`
	DOWNSIZE=`find $PKGNAME -type f -name "*" | xargs stat -c "%-20s %n" | awk -F " " '{ print $1 }'`
else	
	cd $HN_SCRIPT
	# For Non-exist File , Redo the Task from Begin 01_check_update.sh
	01_check_update.sh
	exit 0
fi

# ********** Check File Size between Init and Down **********
if [ "$PKGSIZE" = "$DOWNSIZE" ]
then
	# For Same size ,then set check01=1
	CHECK01=1
elif [ "$PKGSIZE" -gt "$DOWNSIZE" ]
then
	# For InitFileSize is great than DownFileSize ,then , Continue Download Step 
	cd $HN_SCRIPT
	02_check_download.sh
	exit 0
else
	# For InitFileSzie is less  than DownFileSize ,then , File Error. remove file and restart from 01_check_update.sh
	cd $HN_TMP
	rm -rf *
	cd $HN_SCRIPT
	rm -rf $TASK_INF
	01_check_update.sh
	exit 0
fi

# ********** Check File MD5 between Init and Down **********
if [ "$PKG_MD5" = "$DOWN_MD5" ]  
then
	# Base on Size Check, For Same MD5, then set check02=1
	CHECK02=1
else
	# Base on Size Check, For Different MD5, then remove file and restart from 01_check_update.sh
	cd $HN_TMP
	rm -rf *
	cd $HN_SCRIPT
	rm -rf $TASK_INF
	01_check_update.sh
	exit 0
fi

# ********** Check signal and Run upgrade script **********
if [ "$CHECK01" -eq  1 -a "$CHECK02" -eq 1 ]
then
	echo " start update "
	cd $HN_SCRIPT
	rm -rf $REPT_INF

	TASK_ID=`cat $TASK_INF | grep taskid | awk -F "=" '{ print $2 }' | tr -d "\r\n"`
	RPTURL=`cat $TASK_INF | grep rpturl | awk -F "=" '{ print $2 }' | tr -d "\r\n"`

	while [ 1 -eq 1 ]
	do
	
		# Submit download finished to server and get response info to 97_report.ini
    echo "download="`curl -d "taskid=$TASK_ID&action=download" $RPTURL` > $REPT_INF

		SIGNAL=`cat $REPT_INF | grep download | awk -F "=" '{ print $2 }' | tr -d "\r\n"`
		if [ "$SIGNAL" = "success" ]
		then
			echo  " submit ok "
			break
		fi
		sleep 5m
	done	

	04_run_update.sh
	exit 0
fi

exit 0
