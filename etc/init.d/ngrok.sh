#!/bin/sh

. ${__ROOTFS__}/etc/utils/dir.in

if [ -f ${FILE_REGISTER} ]; then                                        
    var=$(cat ${FILE_REGISTER} |jq '.mac')
    echo $var;
    mac=$(echo ${var:1:17} | sed 's/://g')
    echo $mac;   
    /usr/local/ngrok/ngrok-arm -config=/usr/local/ngrok/debug.yml -log=/tmp/ngrok.log -subdomain=$mac 80 &
fi
