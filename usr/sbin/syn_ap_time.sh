#!/bin/sh

#
# for route time syn
#

datestr="`date -I`"
timestr="`date | awk -F " " '{print $4}'`"
/etc/jsock/jmsg.sh asyn timesyn {\"time\":\"${datestr} ${timestr}\"}


