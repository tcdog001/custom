#!/bin/bash

sync_3gstat() {

	local DOWN=down
	local UP=up
	local FILE=/tmp/status/3g_status
	local APfile=/tmp/.ppp/status
	local md3gstat=$( cat $FILE 2>/dev/null )
	local ap3gstat=$( /etc/jsock/jcmd.sh syn "cat $APfile" 2>/dev/null )

	if [ -z  "$md3gstat" ];then
		echo $DOWN >$FILE
	else
		if [ "$md3gstat" != "$ap3gstat" ];then
			if [ "$ap3gstat" == "$UP" ];then
				. /etc/jsock/msg/3g_up.system.cb  2>/dev/null
				echo "$UP" >$FILE
			else
				. /etc/jsock/msg/3g_down.system.cb  2>/dev/null
				echo "$DOWN" >$FILE
			fi
		fi
	fi
}		

main() {
	while :
	do
		sync_3gstat
		sleep 10
	done
}

main "$@"
