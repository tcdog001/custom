#!/bin/sh

if [ ! -x /opt/log/nginx ];then 
	mkdir /opt/log/nginx;
fi

if [ ! -x /opt/log/nginx/logs ];then
	mkdir /opt/log/nginx/logs;
fi

if  [ ! -x /opt/log/nginx/access ];then
	mkdir /opt/log/nginx/access;
fi

if [ ! -x /opt/log/nginx/error ];then
	mkdir /opt/log/nginx/error;
fi                   

nginx -c /usr/local/nginx/conf/nginx.conf -p /opt/log/nginx 2>/dev/null;
