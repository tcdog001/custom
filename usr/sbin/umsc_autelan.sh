#!/bin/bash 

. /etc/um/ums_autelan.in

Ssid="i-shanghai"
dev_info="/data/.register.json"


get_ap_ssid() {
	local userip=$1
        local usermac=$2
        echo "ishanghai.com"
	return 
}
get_ap_mac() {
        echo "22:22:22:22:22:22"
	return 
}
get_ap_lat() {
	echo 11.1111111
	return 
}
get_ap_lng() {
	echo 22.2222222
	return 
}
get_associate_time() {
	local userip=$1
	local usermac=$2
	echo 1970-01-01T08:00:13Z
	return 
}


pre_macfreeauth() {
#auth Param: USERMAC DEVMAC USERIP
	local version=$1
	local uemac=$2
	local apmac=$3
	local ueip=$4  
	
	local associattime=$(get_associat_time ${uemac})##??	
	local apgroup="autelan"
	local apssid=$(get_ap_ssid ${ueip} ${uemac})	
	local aplat=$(get_ap_lat)
	local aplng=$(get_ap_lng)
	
	local result=$(mac_free_auth ${associattime} ${ueip} ${uemac} ${apmac} ${apgroup} ${apssid} ${aplat} ${aplng})
	echo ${result}
	
	return 0 
}
pre_auth() {
#auth Param: USERNAME USERMAC DEVMAC AUTHCODE USERIP
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
	
	local apLat = $(get_ap_lat)
	local apLng = $(get_ap_lng)
	local associateTime = $(get_associate_time ${userip} ${usermac})
	local apSsid = $(get_ap_ssid ${userip} ${usermac})
	local result=$(auth ${username} ${password} ${associateTime} ${userip} ${usermac} ${devmac} ${apSsid} ${apLat} ${apLng})

	echo ${result}
	return 0 
}
pre_register() {
	local version=$1
	local userip=$2
	local usermac=$3
	local username=$4

	if(($# != 4)); then
		echo "1"
		return 1 
	fi

	local apSsid=$(get_ap_ssid ${userip} ${usermac})
        local apMac=${get_ap_mac ${userip} ${usermac}}	

	local result=$(register ${username} ${apMac} ${apSsid})

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
		register|auth|macfreeauth|update|deauth)
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

