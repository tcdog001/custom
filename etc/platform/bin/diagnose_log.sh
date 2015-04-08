#!/bin/bash

. /etc/platform/bin/platform.in
. /etc/upgrade/dir.in 

main() {

	local output=/tmp/syslog.out
	host=oss-cn-hangzhou.aliyuncs.com
	bucket="lms9-autelan-com"
	Id=WRIBSFML486WciQr
	Key=HY5YRv4cfqmbaOmf8JwIjFxPmtootb
	contentType="application/x-compressed-tar"
	
	for file in $(ls ${dir_backup_diagnose}/sys-* | sort -r); do
		
	        filename=${file##*/}	
		
		resource="/${bucket}/${filename}"
		dateValue="`TZ=GMT date +'%a, %d %b %Y %H:%M:%S GMT'`"
		#dateValue=`date -R`
		stringToSign="PUT\n\n${contentType}\n${dateValue}\n${resource}"
		
		signature=`echo -en ${stringToSign} | /usr/local/ssl/bin/openssl sha1 -hmac ${Key} -binary | base64`
		
		curl -i -q -X PUT -T "${file}" \
		 -H "Host: ${host}" \
		  -H "Date: ${dateValue}" \
		  -H "Content-Type: ${contentType}" \
		   -H "Authorization: OSS ${Id}:${signature}" \
		   http://${host}/${bucket}/${filename}
		      	
		rm -f ${file} > /dev/null 2>&1
	done
}

main "$@"

