#!/bin/bash 

. /etc/um/umsclient.in

Ssid="i-shanghai"
dev_info="/data/.register.json"

pre_auth() {
#umsc_auth Param: USERNAME USERMAC DEVMAC AUTHCODE SSID USERIP
	local version=$1
	local userip=$2
	local usermac=$3
	local username=$4
	local password=$5

	if(($# != 5)); then
		echo "1"
		return 1
	fi
	local json=`cat ${dev_info}`
	local devmac=$(echo "${json}" | jq -j ".mac")

	local result=$(umsc_auth ${username} ${usermac} ${devmac} ${password} ${Ssid} ${userip})

	echo ${result}
	return 0 
}
pre_register() {
#umsc_register Param: USERNAME	
	local version=$1
	local userip=$2
	local usermac=$3
	local username=$4

	if(($# != 4)); then
		echo "1"
		return 1 
	fi

	local result=$(umsc_register ${username})

	echo ${result}
	return ${result}
}

pre_deauth() {
	#umsc_deauth Param: USERMAC #REASON
	local usermac=$1		
	#local reason=$2

	if(($# != 1)); then
		echo "1"
		return 1 
	fi

	local oneline=`umc show "{\"mac\":\"$usermac\"}"`
	local reason=`echo $oneline | jq ".reason"`

	echo "usermac=${usermac} reason=${reason}" >> ${umsc_log}
	local result=$(umsc_deauth ${usermac} ${reason})
	echo ${result}	
	return ${result} 
}

pre_update() {
	#msc_update Param: USERMAC FLOWUP FLOWDOWN
	umc show | while read oneline
	do
	echo "updatel" >> ${umsc_log}
	state=`echo $oneline | jq -j ".state"`
	if [[ ${state} != "auth" ]]; then
		continue
	fi 
	usermac=`echo $oneline | jq -j ".mac"` 
	flowup=`echo $oneline | jq -j ".limit.wan.flow.up.now"`
	flowdown=`echo $oneline | jq -j ".limit.wan.flow.down.now"`

	echo "update mac=$mac flowup=$flowup flowdown=$flowdown" >> ${umsc_log}
	local result=$(umsc_update ${usermac} ${flowup} ${flowdown})
	echo ${result}

	done
	return 0
}
main(){
	local action="$1"; shift
	local result
	#echo "$action $@" 

	case ${action} in 
		register|auth|update|deauth)
			result=$(pre_${action} "$@")
			echo ${result}
			return 0
			;;
		*)
			return 1
			;;
	esac
}
main "$@"

