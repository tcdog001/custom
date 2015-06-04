#!/bin/bash

filepath="group0"
landev="eth0.1"
vlandev="ifb0"

if [ $# == 1 ]; then
	if [ $1 == "cleanall" ]; then
		tc qdisc del dev $landev root 2> /dev/null	
		tc qdisc del dev $vlandev root 2> /dev/null	
		return 0
	fi
fi

if [ ! -f "$filepath" ]; then
	echo "Error:couldn't find $filepath"
	exit 1
fi

intdownrate=`awk '/intdownrate/{print $2}'  $filepath`
intuprate=`awk '/intuprate/{print $2}'  $filepath`
locdownrate=`awk '/locdownrate/{print $2}'  $filepath`
locuprate=`awk '/locuprate/{print $2}'  $filepath`

echo "$intdownrate  $intuprate $locdownrate $locuprate"

####for down load####

INET="192.168.0."
 

IPS="15" 
IPE="15"

shell="tc qdisc del dev $landev root 2> /dev/null"
echo "$shell" | sh; echo "$shell"
shell="tc qdisc add dev $landev root handle 1: htb default 40"
echo "$shell" | sh; echo "$shell"

i=$IPS;
while [ $i -le $IPE ]
do
	shell="tc class add dev $landev parent 1: classid 1:2$i htb rate "$locdownrate"kbit ceil "$locdownrate"kbit burst 50k cburst 50k quantum 1500"
	echo "$shell" | sh; echo "$shell"
	shell="tc filter add dev $landev parent 1: prio 1  protocol ip u32  match ip src 192.168.0.1/24 match ip dst $INET$i flowid 1:2$i"	
	echo "$shell" | sh; echo "shell"

	shell="tc class add dev $landev parent 1: classid 1:3$i htb rate "$intdownrate"kbit ceil "$intdownrate"kbit burst 50k cburst 50k quantum 1500"
	echo "$shell" | sh; echo "$shell"
	shell="tc filter add dev $landev parent 1: prio 10  protocol ip u32 match ip dst $INET$i flowid 1:3$i"	
	echo "$shell" | sh; echo "$shell"

i=`expr $i + 1`
done

doEXE(){
####for up load####

shell="tc qdisc del dev $vlandev root 2> /dev/null"
echo "$shell" | sh; echo "$shell"
shell="ifconfig $vlandev up"
echo "$shell" | sh; echo "$shell"
shell="tc qdisc add dev $landev handle ffff: ingress > /dev/null"
echo "$shell" | sh; echo "$shell"
shell="tc filter add dev $landev parent ffff: protocol ip u32 match u32 0 0 action mirred egress redirect dev $vlandev"
echo "$shell" | sh; echo "$shell"
shell="tc qdisc add dev $vlandev root handle 1: htb default 40" 
echo "$shell" | sh; echo "$shell"

j=$IPS
while [ $j -le $IPE ]
do
	shell="tc class add dev $vlandev parent 1: classid 1:2$j htb rate "$locuprate"Kbit ceil "$locuprate"Kbit  quantum 1500"
	echo "$shell" | sh; echo "$shell"
	shell="tc filter add dev $vlandev parent 1: protocol ip prio 1 u32 match ip dst 192.168.0.0/24 match ip src $INET$j flowid 1:2$j"
	echo "$shell" | sh; echo "$shell"

	shell="tc class add dev $vlandev parent 1: classid 1:3$j htb rate "$intuprate"Kbit ceil "$intuprate"Kbit quantum 1500"
	echo "$shell" | sh; echo "$shell"
	shell="tc filter add dev $vlandev parent 1: protocol ip prio 10 u32 match ip src $INET$j flowid 1:3$j"
	echo "$shell" | sh; echo "$shell"

j=`expr $j + 1`
done

}
doEXE


