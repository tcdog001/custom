#!/bin/bash



ip=$1
groupnu=$2
filepath="/etc/um/group$groupnu"
landev="eth0.1"
vlandev="ifb0"
logfile="/tmp/log/umdsh.log"

if [ $# != 2 ]; then
	echo "USEAGE:change_tc ip groupnum" >> ${logfile}
	exit 1
fi

if [[ ! -f ${filepath} ]]; then
	echo "Error:couldn't find $filepath" >> ${logfile} 
	exit 1
fi
#判断ip格式
echo "$ip" |awk -F '.' '{ if ( ( $1 > 256 || $1 < 0 ) || ( $2 > 256 || $2 < 0 ) || ( $3 > 256  || $3 < 0 ) || ( $4 > 256 || $4 < 0 )) {print $0 ,"is incorrect"; exit 3}}'
if [ $? -eq 3 ]; then
	exit 1
fi

#echo "$filepath"

intdownrate=`awk '/intdownrate/{print $2}'  ${filepath}`
intuprate=`awk '/intuprate/{print $2}'  ${filepath}`
locdownrate=`awk '/locdownrate/{print $2}'  ${filepath}`
locuprate=`awk '/locuprate/{print $2}'  ${filepath}`

echo "$intdownrate  $intuprate $locdownrate $locuprate"

if [[ ! ${intdownrate} =~ ^[0-9]+$ ]] ;then
        echo "intdownrate=$intdownrate value error!" >> ${logfile} 
        exit 1 
fi

if [[ ! ${intuprate} =~ ^[0-9]+$ ]] ;then
        echo "intuprate=$intuprate value error!" >> ${logfile} 
        exit 1
fi

if [[ ! ${locdownrate} =~ ^[0-9]+$ ]] ;then
        echo "locdownrate=$locdownrate value error!" >> ${logfile} 
        exit 1
fi

if [[ ! ${locuprate} =~ ^[0-9]+$ ]] ;then
        echo "locuprate=$locuprate value error!" >> ${logfile} 
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



