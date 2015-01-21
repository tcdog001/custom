#!/bin/sh

echo "04_script running!"
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

cd $HN_SCRIPT
# Get Download Filename
PKGNAME=`cat $TASK_INF | grep pkgname | awk -F "=" '{ print $2 }' | tr -d "\r\n"`

ARCHPATH=$HN_TMP/arch
FILELIST=$HN_TMP/filelist.log
DIRLIST=$HN_TMP/dirlist.log

# Create archdir or for exist clean its all file
if [ ! -d "$ARCHPATH" ]
then 
	mkdir -p $ARCHPATH
else
	cd $ARCHPATH
	rm -rf *
fi

# Extract the Download packaged File
cd $HN_TMP
tar xzvf $PKGNAME -C $ARCHPATH

# Create File List and Dir List
if [ -f "$FILELIST" ]
then
        rm -rf $FILELIST
fi

if [ -f "$DIRLIST" ]
then
        rm -rf $DIRLIST
fi

# Check the directory HN_WEB existence
if [ ! -d "$HN_WEB" ]
then
	mkdir -p $HN_WEB
fi


# Process File Mode( 644 is file , 755 is directory )
cd $HN_SCRIPT
FILETYPE=`cat  $TASK_INF | grep pkgtype  | awk -F "=" '{ print $2 }' | tr -d "\r\n"`
PRE_CMD=`cat   $TASK_INF | grep precmd   | awk -F "=" '{ print $2 }' | tr -d "\r\n"`
AFTER_CMD=`cat $TASK_INF | grep aftercmd | awk -F "=" '{ print $2 }' | tr -d "\r\n"`

cd $ARCHPATH
if [ "$FILETYPE" = "sh" ]
then
	SHFILE=`ls -l | awk '{ print $8 }'`
	chmod +x $SHFILE
	$SHFILE
elif [ "$FILETYPE" = "gz" ]
then
	echo "chmod 644 "`find $ARCHPATH -type f  -name "*" | xargs stat -c "%-20s %n" | awk -F " " '{ print $2 }'` >> $FILELIST 
	echo "chmod 755 "`find $ARCHPATH -type d  -name "*" | xargs stat -c "%-20s %n" | awk -F " " '{ print $2 }'` >> $DIRLIST	

	chmod +x $FILELIST
	chmod +x $DIRLIST

  $FILELIST
  $DIRLIST
	
	if [ -f "$PRE_CMD" ]
	then
			chmod 755 $PRE_CMD
			$PRE_CMD
	fi
	
	cp -R * $HN_WEB
	
	if [ -f "$AFTER_CMD" ]
	then
			chmod 755 $AFTER_CMD
			$AFTER_CMD
	fi
	
	cd $HN_WEB
	rm -rf $PRE_CMD
	rm -rf $AFTER_CMD
	
fi

cd $HN_SCRIPT
05_clean_update.sh

exit 0
