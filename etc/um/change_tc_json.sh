#!/bin/bash


ip=$1
mac=$2
json=$3
landev="eth0.1"
vlandev="ifb0"
logfile="/tmp/log/umdsh.log"

if [ $# != 3 ]; then
	echo "USEAGE:change_tc ip groupnum" >> ${logfile}
	exit 1
fi

#判断ip格式
echo "$ip" |awk -F '.' '{ if ( ( $1 > 256 || $1 < 0 ) || ( $2 > 256 || $2 < 0 ) || ( $3 > 256  || $3 < 0 ) || ( $4 > 256 || $4 < 0 )) {print $0 ,"is incorrect"; exit 3}}'
if [ $? -eq 3 ]; then
	exit 1
fi

#echo "$filepath"
intdownrate=`echo ${json} | jq limit.wan.rate.down`
intuprate=`echo ${json} | jq limit.wan.rate.up`
locuprate=`echo ${json} | jq limit.lan.rate.up`
locdownrate=`echo ${json} | jq limit.lan.rate.down`

$intdownrate=`echo ${intdownrate} | sed 's/\"//g'`
$intuprate=`echo ${intuprate} | sed 's/\"//g'`
$locdownrate=`echo ${locdownrate} | sed 's/\"//g'`
$locuprate=`echo ${locuprate} | sed 's/\"//g'`

echo "$intdownrate  $intuprate $locdownrate $locuprate"

expr ${intdownrate} + ${intuprate} + ${locdownrate} + ${locuprate} &>/dev/null
if [[ $? -ne 0 ]]; then
	echo "$filepath value error"
	exit 1	
fi
####for down load####
	i=`echo $ip | awk -F"." '{print $4}'`
	
	shell="tc class change dev ${landev} parent 1: classid 1:2${i} htb rate ${locdownrate}kbit ceil ${locdownrate}kbit burst 50k cburst 50k quantum 1500"
	echo "$shell" | sh; echo ${shell}

	shell="tc class change dev ${landev} parent 1: classid 1:3$i htb rate ${intdownrate}kbit ceil ${intdownrate}kbit burst 50k cburst 50k quantum 1500"
	echo "$shell" | sh; echo ${shell}


####for up load####

	j=`echo $ip | awk -F"." '{print $4}'`

	shell="tc class change dev ${vlandev} parent 1: classid 1:2${j} htb rate ${locuprate}Kbit ceil ${locuprate}Kbit  quantum 1500"
	echo "$shell" | sh; echo ${shell}

	shell="tc class change dev ${vlandev} parent 1: classid 1:3${j} htb rate ${intuprate}Kbit ceil ${intuprate}Kbit quantum 1500"
	echo "${shell}" | sh; echo ${shell}



