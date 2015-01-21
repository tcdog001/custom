#!/bin/sh

PATH=.:$PATH
export PATH

#check and set HN_HOME
if [ ! -d /data/zjhn ]
then
	mkdir -p /data/zjhn
fi
HN_HOME="/data/zjhn"
export HN_HOME

#check and set HN_WEB
HN_WEB=$HN_HOME/www
if [ ! -d "$HN_WEB" ]
then
	mkdir -p $HN_WEB
fi

#check and set HN_CONF
HN_CONF=$HN_HOME/conf
if [ ! -d "$HN_CONF" ]
then
        mkdir -p $HN_CONF
fi

#check and set HN_TMP
HN_TMP=$HN_HOME/tmp
if [ ! -d "$HN_TMP" ]
then
        mkdir -p $HN_TMP
fi

#check and set HN_SCRIPT
HN_SCRIPT=$HN_HOME/script
if [ ! -d "$HN_SCRIPT" ]
then
        mkdir -p $HN_SCRIPT
fi

#check and set HN_NET
HN_NET=$HN_HOME/net
if [ ! -d "$HN_NET" ]
then
        mkdir -p $HN_NET
fi

#check and set HN_IMG
HN_IMG=$HN_HOME/img
if [ ! -d "$HN_IMG" ]
then
        mkdir -p $HN_IMG
fi

#Export the Env for HN_XXXX
export HN_WEB
export HN_CONF
export HN_TMP
export HN_SCRIPT
export HN_NET
export HN_IMG

#Export for temp operation directory
ARCHPATH=$HN_TMP/arch
export ARCHPATH


