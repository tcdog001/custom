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

#读默认的group的参数
def_groupno=0
def_group="/etc/um/group${def_groupno}"
echo "${def_group}"

def_intdownrate=`awk '/wan_rate_down/{print $2}'  ${def_group}`
def_intuprate=`awk '/wan_rate_up/{print $2}'  ${def_group}`
def_locdownrate=`awk '/lan_rate_down/{print $2}'  ${def_group}`
def_locuprate=`awk '/lan_rate_up/{print $2}'  ${def_group}`

#解析json字符串
#echo "$filepath"
intdownratemax=`echo ${json} | jq -j -c ".limit.wan.rate.down.max"`
intdownrateavg=`echo ${json} | jq -j -c ".limit.wan.rate.down.avg"`
intupratemax=`echo ${json} | jq -j -c ".limit.wan.rate.up.max"`
intuprateavg=`echo ${json} | jq -j -c ".limit.wan.rate.up.avg"`
locupratemax=`echo ${json} | jq -j -c ".limit.lan.rate.up.max"`
locuprateavg=`echo ${json} | jq -j -c ".limit.lan.rate.up.avg"`
locdownratemax=`echo ${json} | jq -j -c ".limit.lan.rate.down.max"`
locdownrateavg=`echo ${json} | jq -j -c ".limit.lan.rate.down.avg"`

#$intdownratemax=`echo ${intdownratemax} | sed 's/\"//g'`
#$intdownrateavg=`echo ${intdownrateavg} | sed 's/\"//g'`
#$intupratemax=`echo ${intupratemax} | sed 's/\"//g'`
#$intuprateavg=`echo ${intuprateavg} | sed 's/\"//g'`
#$locdownratemax=`echo ${locdownratemax} | sed 's/\"//g'`
#$locdownrateavg=`echo ${locdownrateavg} | sed 's/\"//g'`
#$locupratemax=`echo ${locupratemax} | sed 's/\"//g'`
#$locuprateavg=`echo ${locuprateavg} | sed 's/\"//g'`

expr 1 + ${intdownratemax} + ${intdownrateavg} + ${intupratemax} + ${intuprateavg} + ${locdownratemax} + ${locdownrateavg} + ${locupratemax} + ${locuprateavg}  &>/dev/null
if [[ $? -ne 0 ]]; then
	echo "$filepath value error"
	exit 1	
fi

#判断json参数值是否为0，如果为0，取默认值
if(($intdownratemax==0)); then
	intdownratemax=${def_intdownrate}
	intdownrateavg=${def_intdownrate}
fi
if(($intupratemax==0)); then
	intupratemax=${def_intuprate}
	intuprateavg=${def_intuprate}
fi
if(($locupratemax==0)); then
	locupratemax=${def_locuprate}
	locuprateavg=${def_locuprate}
fi
if(($locdownratemax==0)); then
	locdownratemax=${def_locdownrate}
	locdownrateavg=${def_locdownrate}
fi

#下发策略
####for down load####
	i=`echo $ip | awk -F"." '{print $4}'`
	
	shell="tc class change dev ${landev} parent 1: classid 1:2${i} htb rate ${locdownrateavg}kbit ceil ${locdownratemax}kbit burst 50k cburst 50k quantum 1500"
	echo "$shell" | sh; echo ${shell}

	shell="tc class change dev ${landev} parent 1: classid 1:3$i htb rate ${intdownrateavg}kbit ceil ${intdownratemax}kbit burst 50k cburst 50k quantum 1500"
	echo "$shell" | sh; echo ${shell}


####for up load####

	j=`echo $ip | awk -F"." '{print $4}'`

	shell="tc class change dev ${vlandev} parent 1: classid 1:2${j} htb rate ${locuprateavg}Kbit ceil ${locupratemax}Kbit  quantum 1500"
	echo "$shell" | sh; echo ${shell}

	shell="tc class change dev ${vlandev} parent 1: classid 1:3${j} htb rate ${intuprateavg}Kbit ceil ${intupratemax}Kbit quantum 1500"
	echo "${shell}" | sh; echo ${shell}



