#!/bin/sh

if [ ! -x /data/opt/log/nginx ];then 
	mkdir /data/opt/log/nginx;
fi

if [ ! -x /data/opt/log/nginx/logs ];then
	mkdir /data/opt/log/nginx/logs;
fi

if  [ ! -x /data/opt/log/nginx/access ];then
	mkdir /data/opt/log/nginx/access;
fi

if [ ! -x /data/opt/log/nginx/error ];then
	mkdir /data/opt/log/nginx/error;
fi                   

nginx -c /usr/local/nginx/conf/nginx.conf -p /data/opt/log/nginx 2>/dev/null;
