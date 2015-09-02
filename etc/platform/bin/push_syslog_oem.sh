#!/bin/bash

. /etc/platform/bin/syslog_oem.in

dir_tmp_log_backup=${dir_backup_log}
main() {
	local err=0
        local output=/tmp/syslog.out
        local host=oss-cn-hangzhou.aliyuncs.com
        local bucket="lms9-autelan-com"
        local Id=WRIBSFML486WciQr
        local Key=HY5YRv4cfqmbaOmf8JwIjFxPmtootb
        local contentType="application/x-compressed-tar"
	local status
        local file

	pushd ${dir_tmp_log_backup} 1> /dev/null

        for file in $(ls ${dir_tmp_log_backup}/sys-* | sort -r); do

	        filename=${file##*/}
		resource="/${bucket}/${filename}"
		dateValue=$(TZ=GMT date +'%a, %d %b %Y %H:%M:%S GMT')
		stringToSign="PUT\n\n${contentType}\n${dateValue}\n${resource}"		
		signature=`echo -en ${stringToSign} | OPENSSL_CONF=/usr/local/ssl/openssl.cnf /usr/local/ssl/bin/openssl sha1 -hmac ${Key} -binary | base64`

                status=$(curl -i -s -q -X PUT -T "${file}" \
                                        -o ${output} \
                                        -H "Host: ${host}" \
					-H "Date: ${dateValue}" \
                                        -H "Content-Type: ${contentType}" \
                                        -H "Authorization: OSS ${Id}:${signature}" \
                                        -w  %{http_code} \
                                        http://${host}/${bucket}/${filename}); err=$?

                if [ "${status}" = "200" ]; then
			rm -f ${file} > /dev/null 2>&1
                else
                        echo_logger "platform" \
                                "ERROR[${err}]: upload ${file} failed"
			popd 1> /dev/null
                        return ${err}
		fi

        done
	popd 1> /dev/null
}

main_old() {
        local err=0
	local mac=$(get_mac) || return $?

	local signature=$(cat /etc/platform/conf/encrypt_data_sys.dat)
	local output=/tmp/syslog.out

	local file
	for file in $(ls ${dir_tmp_log_backup}/sys-* | sort -r); do
		local newname=$(basename ${file})
		newname=${newname#sys-}
		newname=${newname//:/-}

		local status=$(curl -s \
					--max-time 180 \
					-F "type=sys" \
					-F "signature=${signature}" \
					-F "ident=${mac}" \
					-F "content=@${file};filename=${newname};type=text/plain" \
					-o ${output} \
					-w  %{http_code} \
					http://update1.9797168.com:821/wifibox/); err=$?
		if [ "${status}" != "200" ]; then
			echo_logger "platform" \
				"ERROR[${err}]: upload ${file} failed"
			return ${err}
		elif [ "true" != "$(cat ${output} | jq -j '.success|booleans')" ]; then
			echo_logger "platform" \
				"upload ${file} failed"
			return 1
		fi

		rm -f ${file} > /dev/null 2>&1
	done
}

main "$@"

