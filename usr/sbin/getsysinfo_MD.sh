#!/bin/sh

get_cpu_Frequency() {
	cpu0Frequency=`cat /proc/cpuinfo |awk -F ':' '/BogoMIPS/{print $2}' |sed -n '1p'`
	cpu1Frequency=`cat /proc/cpuinfo |awk -F ':' '/BogoMIPS/{print $2}' |sed -n '2p'`
	if [ -z "$cpuFrequency" ];then
		cpuFrequency="NULL"
	fi
	echo "$cpu0Frequency"-"$cpu1Frequency"
}

get_cpu_use() {
	cpuUse=`top -n 1 |awk '{print $8}' |sed '1,4d' |awk '{sum += $1};END {print sum}'`
	if [ -z "$cpuUse" ];then
		cpuUse="0%"
	fi
	echo "$cpuUse%"
}

get_memory_size() {
	memorySize=`free |awk -F ' ' '/Mem:/{print $2}'`
	if [ -z "$memorySize" ];then
		memorySize="1750336"
	fi
	echo "$memorySize"
}

get_memory_use() {
	memoryUse=`free |awk -F ' ' '/Mem:/{print $3}'`
	memoryUsage1=`awk 'BEGIN{printf "%.2f\n",'$memoryUse'/'$memorySize'*100}'`
	memoryUsage="`echo $memoryUsage1%`"
	if [ -z "$memoryUsage" ];then	
		memoryUsage="0%"
	fi
	echo "$memoryUsage"
}

get_board_ONOFFtime() {
	boardONtime=`cat /data/md-on |sed -n '$p'`
	if [ -z "$boardONtime" ];then
		boardONtime="NO ON TIME"
	fi
	echo "$boardONtime"
}

get_ssd_Size() {
	ssdSize=`hdparm -i /dev/sda |awk -F ' ' '/Model=FORESEE/{print $2}'`
	if [ -z "$ssdSize" ];then
		ssdSize="128G"
	fi
	echo "$ssdSize"
}

get_ssd_partSize() {
	ssdpartSize=`hdparm -i /dev/sda1 |awk -F ' ' '/Model=FORESEE/{print $2}'`
	if [ -z "$ssdpartSize" ];then
		ssdpartSize="128G"
	fi
	echo "$ssdpartSize"
}

get_ssd_Usage() {
	ssdUsage=`df -h /dev/sda1 |awk -F ' ' '{print $5}' |sed -n '$p'`
	if [ -z "$ssdUsage" ];then
		ssdUsage="0%"
	fi
	echo "$ssdUsage"
}

get_ssd_Temperature() {
	echo "0"
}

get_ssd_uptime() {
	echo "0"
}

get_ssd_upnum() {
	echo "0"
}

get_ssd_badpartnum() {
	echo "0"
}

get_ssd_erasenum() {
	echo "0"
}

get_ssd_dropnum() {
	echo "0"
}

get_view_Signal() {
	viewSignal=``
	if [ -z "$viewSignal" ];then
		viewSignal="NO ERROR"
	fi
	echo "$viewSignal"
}

get_view_Check() {
	viewCheck=``
	if [ -z "$viewCheck" ];then
		viewCheck="NO ERROR"
	fi
	echo "$viewCheck"
}

get_media_info() {
	local cpuFrequency=$(get_cpu_Frequency)
	local cpuUse=$(get_cpu_use)
	local memorySize=$(get_memory_size)
	local memoryUse=$(get_memory_use)
	local boardONOFFtime=$(get_board_ONOFFtime)
	local ssdSize=$(get_ssd_Size)
	local ssdPartSize=$(get_ssd_partSize)
	local ssdUsage=$(get_ssd_Usage)
	local ssdTemperature=$(get_ssd_Temperature)
	local ssdUptime=$(get_ssd_uptime)
	local ssdUpnum=$(get_ssd_upnum)
	local ssdBadpartnum=$(get_ssd_badpartnum)
	local ssdErasenum=$(get_ssd_erasenum)
	local ssdDropnum=$(get_ssd_dropnum)
	local viewSignal=$(get_view_Signal)
	local viewCheck=$(get_view_Check)
	
	printf '{"MDcpuFrequency":"%s","MDcpuUse":"%s","MDmemorySize":"%s","MDmemoryUse":"%s","boardONtime":"%s","ssdSize":"%s","ssdPartSize":"%s","ssdUsage":"%s","ssdTemperature":"%s","ssdUptime":"%s","ssdUpnum":"%s","ssdBadpartnum":"%s","ssdErasenum":"%s","ssdDropnum":"%s","viewSignal":"%s","viewCheck":"%s"}\n'   \
		"${cpuFrequency}"	\
		"$cpuUse"		\
		"$memorySize"		\
		"$memoryUse"		\
		"$boardONOFFtime"	\
		"$ssdSize"		\
		"$ssdPartSize"		\
		"$ssdUsage"		\
		"$ssdTemperature"	\
		"$ssdUptime"		\
		"$ssdUpnum"		\
		"$ssdBadpartnum"	\
		"$ssdErasenum"		\
		"$ssdDropnum"		\
		"$viewSignal"		\
		"$viewCheck"
}

main() {
	get_media_info >/tmp/getsysinfo_MD.json 2>/dev/null
}

main "$@"
