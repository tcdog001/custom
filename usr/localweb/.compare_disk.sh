#!/bin/sh

index0925=`cat /usr/localweb/.index.md5sum`
nochkCode0925=`cat /usr/localweb/.nochkCode.md5sum`
logSec0925=`cat /usr/localweb/.logSec.md5sum`

indexnew=`md5sum /mnt/hd/website/index.html |awk -F ' ' '{print $1}' 2>/dev/null`
nochkCodenew=`md5sum /mnt/hd/website/nochkCode.php |awk -F ' ' '{print $1}' 2>/dev/null`
logSecnew=`md5sum /mnt/hd/website/logSec.html |awk -F ' ' '{print $1}' 2>/dev/null`

i=1;
while(( $i < 4 ))
do

i=$i+1;

if [ -e /mnt/hd/website/index.html ];then
	if [ $index0925 != $indexnew ];then
		rm -rf /mnt/hd/website/index.html 2>/dev/null
		cp /usr/localweb/.index.html /mnt/hd/website/index.html 2>/dev/null
		chmod 777 /mnt/hd/website/index.html
	fi
else
	cp /usr/localweb/.index.html /mnt/hd/website/index.html 2>/dev/null
	chmod 777 /mnt/hd/website/index.html 
fi

if [ -e /mnt/hd/website/nochkCode.php ];then
	if [ $nochkCode0925 != $nochkCodenew ];then
		rm -rf /mnt/hd/website/nochkCode.php 2>/dev/null
		cp /usr/localweb/.nochkCode.php /mnt/hd/website/nochkCode.php 2>/dev/null
		chmod 777 /mnt/hd/website/nochkCode.php
	fi
else
	cp /usr/localweb/.nochkCode.php /mnt/hd/website/nochkCode.php 2>/dev/null
	chmod 777 /mnt/hd/website/nochkCode.php 
fi

if [ -e /mnt/hd/website/logSec.html ];then
	if [ $logSec0925 != $logSecnew ];then
		rm -rf /mnt/hd/website/logSec.html 2>/dev/null
		cp /usr/localweb/.logSec.html /mnt/hd/website/logSec.html 2>/dev/null
		chmod 777 /mnt/hd/website/logSec.html
	fi
else
	cp /usr/localweb/.logSec.html /mnt/hd/website/logSec.html 2>/dev/null    
	chmod 777 /mnt/hd/website/logSec.html 
fi
	
done

