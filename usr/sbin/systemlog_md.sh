#!/bin/bash

. /etc/upgrade/dir.in
ERROR_NOSUPPORT="Not supported"

car_system_now=$(getnow)

get_temp() {
    local string=$(temperature_show | awk '{print $3}')

    echo ${string}
}

get_cpu_use() {
    local cpuUse=$(top -n 1 |awk '{print $8}' |sed '1,4d' |awk '{sum += $1};END {print sum}')

    if [[ -z ${cpuUse} ]]; then
        cpuUse="0%"
    fi
    echo "${cpuUse}%"
}

get_memory_use() {
    local memorySize=$(free |awk -F ' ' '/Mem:/{print $2}')
    local memoryUse=$(free |awk -F ' ' '/Mem:/{print $3}')
    local memoryUsage1=$(awk 'BEGIN{printf "%.2f\n",'${memoryUse}'/'${memorySize}'*100}')
    local memoryUsage=$(echo ${memoryUsage1}%)

    if [[ -z ${memoryUsage} ]]; then
        memoryUsage="0%"
    fi
    echo ${memoryUsage}
}

get_ssd_Usage() {
    local ssdUsage=$(df -h /dev/sda1 |awk -F ' ' '{print $5}' |sed -n '$p')

    if [[ -z ${ssdUsage} ]]; then
        ssdUsage="0%"
    fi
    echo ${ssdUsage}
}

get_ssd_erasenum() {
    echo "${ERROR_NOSUPPORT}"
}

#
# $1: string
# $2: path and filename
#
str_output() {
    local string="$1"
    local path="$2"

    echo ${string} > ${path}
}

#
# $1: key
# $2: value; shift 2
# $@: json string
#
add_json_string() {
    local key="$1"
    local value="$2"; shift 2
    local str_old="$@"
    local str_new="\"${key}\": \"${value}\""
    local str_entirety
    
    if [[ ${str_old} ]]; then
        str_entirety="${str_old}, ${str_new}"
    else
        str_entirety=${str_new}
    fi

    echo ${str_entirety}
}

#
# $@: json string
#
str_systemlog_ap() {
    local jsonstr="$@"
    # file_systemlog_ap from /etc/utils/dir.in
    local jsonap=$(cat ${file_systemlog_ap})
 
    [[ ${jsonap} ]] && jsonstr="${jsonstr}, ${jsonap}"
    [[ ${jsonstr} ]] && echo ${jsonstr}
}

#
# $@: json string
#
str_systemlog_md() {
    local jsonstr="$@"

    jsonstr=$(add_json_string "date" "${car_system_now}" "${jsonstr}")
    jsonstr=$(add_json_string "cpu_temp" "$(get_temp)" "${jsonstr}")
    jsonstr=$(add_json_string "cpu" "$(get_cpu_use)" "${jsonstr}")
    jsonstr=$(add_json_string "process_num" "$(ps -w | wc -l)" "${jsonstr}")
    jsonstr=$(add_json_string "memory" "$(get_memory_use)" "${jsonstr}")
    jsonstr=$(add_json_string "disk_used" "$(get_ssd_Usage)" "${jsonstr}")
    jsonstr=$(add_json_string "disk_erased" "$(get_ssd_erasenum)" "${jsonstr}")

    [[ ${jsonstr} ]] && echo ${jsonstr}
}

main() {
    # function getnow from /etc/utils/time.in
    local logname="car_system-${car_system_now}.log"
    local jsonstr=""

    jsonstr=$(str_systemlog_md ${jsonstr})
    jsonstr=$(str_systemlog_ap ${jsonstr})

    # dir_opt_log_dev_monitor from etc/upgrade/dir.in
    str_output "{ ${jsonstr} }" "${dir_opt_log_dev_monitor}/${logname}"
}

main "$@"
