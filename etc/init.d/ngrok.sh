#!/bin/sh

if [ -f  /data/.register.json ];then                                        
    var=`cat /data/.register.json  |jq '.mac'`         
    echo $var;
    mac=` echo ${var:1:17} | sed 's/://g'`
    echo $mac;   
    /usr/local/ngrok/ngrok-arm -config=/usr/local/ngrok/debug.yml -log=/tmp/ngrok.log -subdomain=$mac 80 &
fi
