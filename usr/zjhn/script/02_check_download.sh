#!/bin/sh
echo "02_script running!"
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

cd $HN_SCRIPT
NEWTASKID=`cat $TASK_INF | grep taskid | awk -F "=" '{ print $2 }' | tr -d "\r\n"`
FORCEFLAG=`cat $TASK_INF | grep force  | awk -F "=" '{ print $2 }' | tr -d "\r\n"`

# If the 98_status.ini exist ,its content was last succeed taskid
if [ -f "$FLAG_INF" ]
then
	OLDTASKID=`cat $FLAG_INF | grep taskid | awk -F "=" '{ print $2 }' | tr -d "\r\n"`
else
	OLDTASKID="ndy"
fi

if [ ! -d "$HN_TMP" ]
then
        mkdir -p $HN_TMP
fi

# Judgement the different taskid
if [ "$NEWTASKID" != "$OLDTASKID" ]
then
	CONT_A=1
else
	CONT_A=0
fi

# Judgement the same taskid with force signal
if [ "$NEWTASKID" = "$OLDTASKID" -a "$FORCEFLAG" = "1" ]
then
	CONT_B=1
else
	CONT_B=0
fi

# run the download 
if [ "$CONT_A" -eq 1 -o "$CONT_B" -eq 1 ]
then
	cd $HN_SCRIPT
	DLURL=`cat $TASK_INF | grep pkgurl | awk -F "=" '{ print $2 }' | tr -d "\r\n"`

	# Judge the $DLURL, if empty then retry, or start download 
	if [ -z "$DLURL" ]
	then
		cd $HN_SCRIPT
		rm -rf TASK_INF
		01_check_update.sh
		exit 0
	else
		cd $HN_TMP
		wget -c $DLURL
	fi
	
	cd $HN_SCRIPT
	03_check_file.sh
	exit 0
else
	exit 0
fi

exit 0
