#!/bin/bash

UmsUserLog="/tmp/umd/log/ums.log"
TempFile="/tmp/umd/log/umcshow.log.temp"
TempLogs="/tmp/umd/log/umsc.log.temp"
UmscLogs="/tmp/umsc.log"
AuthFlag=0

get_connectTime() {
 	local rawline=$1
	local lanuptime=$(echo ${rawline} | jq -j -c ".limit.lan.online.uptime")	
	
	local connecttime=$((`date +%s` - $(date +%s -d "${lanuptime}")))
	echo ${connecttime}
	return 	
}
get_accsessiontime() {
	local rawline=$1
	local state=$(echo ${rawline} | jq -j -c ".state")						
	if[${state} != "auth"]; then
		AuthFlag=1	
		echo ""
		return 
	fi
	local logintime=$(echo ${rawline} | jq -j -c ".limit.wan.online.uptime")
	local accsessiontime=$((`date +%s` - $(date +%s -d "${logintime}")))
	echo ${accsessiontime}
	return 
}

get_accWanOcts_allowance() {
	local rawline=$1 
	local AccWanOcts=$2
	if((AuthFlag==1)); then	

		local flowdownmax=$(echo ${rawline} | jq -j -c ".limit.wan.flow.down.max")	
	
		local allowance=$((${flowdownmax} - ${AccWanOcts}))
		echo ${wllowance}
	else 
		echo 0
	fi
	return 	
}
get_accsessiontime_allowance() {
	local rawline=$1 
	local AccSessionTime=$2
	
	if((AuthFlag==1)); then	
		local wanonlinemax=$(echo ${rawline} | jq -j -c ".limit.wan.online.max")		

		local allowance=$((${wanonlinemax} - ${AccSessionTime})) 
		echo ${allowance}
	else 
		echo 0
	fi
	return 
}
gen_ums_log() {
	
	local rawline=$1
	
	#UeBillId
	local UeMac=$(echo ${rawline} | jq -j -c ".mac")
	local BillState=""
	local UeState=$(echo ${rawline} | jq -j -c ".state")
	local AssociatTime=$(echo ${rawline} | jq -j -c ".limit.lan.online.uptime")
	local LoginTime=$(echo ${rawline} | jq -j -c ".limit.wan.online.uptime")
	local LogTime="1970-01-01T08:00:13Z"
	local UeIp=$(echo ${rawline} | jq -j -c ".ip")
	local UserType="phone"
	#UserName??
	#UserGroup??
	#ApMac
	local ApGroup=""
	#ApSsid
	#ApLat
	#ApLng
	local AccWanOcts=$(echo ${rawline} | jq -j -c ".limit.wan.flow.down.now")
	local AccLanOcts=$(echo ${rawline} | jq -j -c ".limit.lan.flow.down.now")
	local AccSessionTime=$(get_accsessiontime ${rawline})
	local AccWanOctsAllowance=$(get_accWanOcts_allowance ${rawline} ${AccWanOcts})
	local AccSessionTimeAllowance=$(get_accsessiontime_allowance ${rawline} ${AccSessionTime})
	local ConnectTime=$(get_connectTime ${rawline})
	local LogoutTime="1970-01-01T08:00:13Z"
	local AccTerminateCause=""
	
	local json=$(json_create \
       	UeBillId ${UeBillId} \
	UeMac ${UeMac} \
	BillState ${BillState} \
	UeState ${UeState} \	
	AssociatTime ${AssociatTime} \	
	LoginTime ${LoginTime} \	
	LogTime ${LogTime} \
	UeIp ${UeIp} \
	UserType ${UserType} \
	UserName ${UserName} \
	UserGroup ${UserGroup} \
	ApMac ${ApMac} \
	ApGroup ${ApGroup} \
	ApSsid ${ApSsid} \
	ApLat ${ApLat} \
	ApLng ${ApLng} \
	AccWanOcts ${AccWanOcts} \
	AccLanOcts ${AccLanOcts} \
	AccSessionTime ${AccSessionTime} \
	AccWanOctsAllowance ${AccWanOctsAllowance} \
	AccSessionTimeAllowance ${AccSessionTimeAllowance} \
	ConnectTime ${ConnectTime} \
	LogoutTime ${LogoutTime} \
	AccTerminateCause ${AccTerminateCause})		
	echo ${json}
	return 
}
http_upload_log() {
	
	local upload_file=$1

	 local status=$(curl --max-time 180  \
	 -F upload_file=@${upload_file} \
	 -o  ${TempLogs} \
	 -s \
         -w  %{http_code}  \
	 http://192.168.15.22:8282/umlogs/)
	 if [ "$status" -eq "200" ];then
		local outcontent=$(cat ${TempLogs} | jq -j ".success")
                case ${outcontent} in
                true)
                        info="ok"
                        ;;
                false)
                        info="failed"
                        ;;
                *)
                        info="error"
                        ;;
                esac
		echo "$(getnow) upload ${info}" >> ${UmscLogs}
	 fi
}
main() {
	umc show >> ${TempFile} 
	while read LINE
	do
       		local log=$(gen_ums_log "${LINE}") 
		echo ${log} >> ${UmsUserLog}	
	done < ${TempFile}			

	rm ${TempFile}
	
	http_upload_log ${UmsUserLog}
}

main "$@"
