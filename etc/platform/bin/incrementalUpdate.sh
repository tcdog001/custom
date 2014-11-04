#!/bin/sh

. /etc/platform/bin/platform.in

CERTIFICATE=/etc/platform/conf/server.cer
USER_PASSWD=autelanauteviewlms:autelanauteviewlms20140925
URL_PATH=/etc/platform/conf/platform.json
URL_DEFAULT=https://atbus.9797168.com:8443/LMS/lte/
CURRENT_MEDIA_VERSION=incrementalUpdateCurrentMediaVersion.json
CURRENT_ROUTE_VERSION=incrementalUpdateCurrentRouteVersion.json
COOKIE_FILE=incrementalUpdateCookie.txt
PAGE=lteIncrementalUpdate.do
NEW_VERSION_INFO=incrementalUpdateNewVersionInfo.json
NEW_MEDIA_VERSION=incrementalUpdateNewMediaVersion.json
NEW_ROUTE_VERSION=incrementalUpdateNewRouteVersion.json
MEDIA_VERSION_PATH=/mnt/flash/rootfs_data/version/md/
ROUTE_VERSION_PATH=/mnt/flash/rootfs_data/version/ap/
is_media_update=0
is_route_update=0
CURLE_OK=0
CONTINUE_INTERVAL=300
CONTINUE_TIMES=3
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

	curl  -k  -cert $CERTIFICATE  -u $USER_PASSWD  -H "Content-type: application/json"  -X POST  -d $mac  -s  -c $COOKIE_FILE  $url > $NEW_VERSION_INFO
	type=`cat $NEW_VERSION_INFO |jq '.increment[0].type'`
	echo type=$type
	if [ x$type == x"media" ];then
		cat $NEW_VERSION_INFO |jq '.increment[0]' > $NEW_ROUTE_VERSION
		cat $NEW_VERSION_INFO |jq '.increment[1]' > $NEW_MEDIA_VERSION
	else
		cat $NEW_VERSION_INFO |jq '.increment[0]' > $NEW_MEDIA_VERSION
		cat $NEW_VERSION_INFO |jq '.increment[1]' > $NEW_ROUTE_VERSION
	fi
	rm $NEW_VERSION_INFO

	if [ -f $CURRENT_MEDIA_VERSION ];then
		currentMd5=`cat $CURRENT_MEDIA_VERSION |jq '.md5'`
		newMd5=`cat $NEW_MEDIA_VERSION |jq '.md5'`
		if [ x$newMd5 != x$currentMd5 ];then
			is_media_update=1
		fi
	else
		is_media_update=1
	fi
	echo is_media_update=$is_media_update
	if [ $is_media_update -eq 1 ];then
		name=`cat $NEW_MEDIA_VERSION |jq -j '.name'`
		usr=`cat $NEW_MEDIA_VERSION |jq -j '.usr'`
		passwd=`cat $NEW_MEDIA_VERSION |jq -j '.passwd'`
		src=`cat $NEW_MEDIA_VERSION |jq -j '.src'`
		url=`cat $NEW_MEDIA_VERSION |jq -j '.url'`
		md5=`cat $NEW_MEDIA_VERSION |jq -j '.md5'`
		versionNo=`cat $NEW_MEDIA_VERSION |jq -j '.versionNo'`
		patchNo=`cat $NEW_MEDIA_VERSION |jq -j '.patchNo'`
		path=$MEDIA_VERSION_PATH"/$versionNo/"
		versionName="patch-"${patchNo}".tar.gz"
		echo "media_version_info:"$usr--$passwd--$url--$src--$name--$versionNo--$patchNo
		for i in $(seq 1 $CONTINUE_TIMES); do 
			curl -u $usr:$passwd -s -C - -o $versionName ftp://$url/$src/$name
			response=$?
			if [ $response -eq $CURLE_OK ];then
				break
			else
				sleep $CONTINUE_INTERVAL
			fi
		done
		if [ $response -eq $CURLE_OK ];then
			md5Temp=`md5sum $name`
			md5Result=${md5Temp% *}
			if [ x$md5Result == x$md5 ];then
				echo "md5 OK"
				if [ -f $CURRENT_MEDIA_VERSION ];then
					rm $CURRENT_MEDIA_VERSION
				fi
				mv $NEW_MEDIA_VERSION $CURRENT_MEDIA_VERSION
				if [ ! -x $path ];then
					mkdir $path
				fi
				chmod 777 $path
				mv $versionName $path
				/etc/upgrade/upgrade_start.sh "md" $versionNo $versionName
			else
				echo "md5 ERROR"
				if [ -f $NEW_MEDIA_VERSION ];then
					rm $NEW_MEDIA_VERSION
				fi
				if [ -f $name ];then
					rm $name
				fi
			fi
		else
			if [ -f $NEW_MEDIA_VERSION ];then
				rm $NEW_MEDIA_VERSION
			fi
			if [ -f $name ];then
				rm $name
			fi
		fi
	else
		if [ -f $NEW_MEDIA_VERSION ];then
			rm $NEW_MEDIA_VERSION
		fi
	fi

	if [ -f $CURRENT_ROUTE_VERSION ];then
		currentMd5=`cat $CURRENT_ROUTE_VERSION |jq '.md5'`
		newMd5=`cat $NEW_ROUTE_VERSION |jq '.md5'`
		if [ x$newMd5 != x$currentMd5 ];then
			is_route_update=1
		fi
	else
		is_route_update=1
	fi
	echo is_route_update=$is_route_update
	if [ $is_route_update -eq 1 ];then
		name=`cat $NEW_ROUTE_VERSION |jq -j '.name'`
		usr=`cat $NEW_ROUTE_VERSION |jq -j '.usr'`
		passwd=`cat $NEW_ROUTE_VERSION |jq -j '.passwd'`
		src=`cat $NEW_ROUTE_VERSION |jq -j '.src'`
		url=`cat $NEW_ROUTE_VERSION |jq -j '.url'`
		md5=`cat $NEW_ROUTE_VERSION |jq -j '.md5'`
		versionNo=`cat $NEW_ROUTE_VERSION |jq -j '.versionNo'`
		patchNo=`cat $NEW_ROUTE_VERSION |jq -j '.patchNo'`
		path=$ROUTE_VERSION_PATH"/$versionNo/"
		versionName="patch-"${patchNo}".tar.gz"
		echo "route_version_info:"$usr--$passwd--$url--$src--$name--$versionNo--$patchNo
		for i in $(seq 1 $CONTINUE_TIMES); do
			curl -u $usr:$passwd -s -C - -o $versionName ftp://$url/$src/$name
			response=$?
			if [ $response -eq $CURLE_OK ];then
				break
			else
				sleep $CONTINUE_INTERVAL
			fi
		done
		if [ $response -eq $CURLE_OK ];then
			md5Temp=`md5sum $name`
			md5Result=${md5Temp% *}
			if [ x$md5Result == x$md5 ];then
				echo "md5 OK"
				if [ -f $CURRENT_ROUTE_VERSION ];then
					rm $CURRENT_ROUTE_VERSION
				fi
				mv $NEW_ROUTE_VERSION $CURRENT_ROUTE_VERSION
				if [ ! -x $path ];then
					mkdir $path
				fi
				chmod 777 $path
				mv $versionName $path
				/etc/upgrade/upgrade_start.sh "ap" $versionNo $versionName
			else
				echo "md5 ERROR"
				if [ -f $NEW_ROUTE_VERSION ];then
					rm $NEW_ROUTE_VERSION
				fi
				if [ -f $name ];then
					rm $name
				fi
			fi
		else
			if [ -f $NEW_ROUTE_VERSION ];then
				rm $NEW_ROUTE_VERSION
			fi
			if [ -f $name ];then
				rm $name
			fi
		fi
	else
		if [ -f $NEW_ROUTE_VERSION ];then
			rm $NEW_ROUTE_VERSION
		fi
	fi
else
	echo $FILE_REGISTER" is not exist!"
fi
