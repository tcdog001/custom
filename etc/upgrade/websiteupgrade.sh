#!/bin/bash

. ${__ROOTFS__}/etc/upgrade/dir.in
website_config_file=""

#__zj_rsync__=no means "not use zj_rsync_server and zj_rsync_user"
zj_rsync_server=zjweb.autelan.com
zj_rsync_config_server=zjconfig.autelan.com
zj_rsync_user=autelan

#
# $1: remote path, $2: dir, $3: server, $4: user
#
rsync_action() {
	local remote="$1"
	local dir="$2"
	local server="$3"
	local user="$4"

	local port="873"
	local timeout="300"

	#local sshparam="sshpass -p ${pass} ssh -l ${user} -o StrictHostKeyChecking=no"
	local rsync_dynamic=" --timeout=${timeout}"
	local rsync_static="-acz --delete --force --stats --partial"
	local pass="--password-file=/etc/rsyncd.pass"
	local action="rsync ${rsync_dynamic} ${rsync_static} ${user}@${server}::systemver/${remote} ${dir} ${pass}"

	local err=0
	eval "${action}"; err=$?
	return ${err}
}

#
#$1:remote
#$2:dir
#
website_config_rsync() {
	local remote=$1; remote=${remote%/}/
	local dir=$2

	if [[ "${__zj_rsync__}" = "no" ]]; then
		local server="lms1.autelan.com"
		local user="autelan"
	else
		local server=${zj_rsync_config_server}
		local user=${zj_rsync_user}
	fi

	local err=0
	rsync_action ${remote} ${dir} ${server} ${user}; err=$?
	echo_logger "website" "$(get_error_tag ${err}): rsync ${remote}"
	if ((0!=err)); then
		return ${err}
	fi
}

website_rsync() {
	local remote=$1; remote=${remote%/}/
	local dir=$2

	if [[ "${__zj_rsync__}" = "no" ]]; then
		local server="zjweb.autelan.com"
		local user="autelan"
	else
		local server=${zj_rsync_server}
		local user=${zj_rsync_user}
	fi
	
	local err=0
	rsync_action ${remote} ${dir} ${server} ${user}; err=$?
	echo_logger "website" "$(get_error_tag ${err}): rsync ${remote}"
	if ((0!=err)); then
		return ${err}
	fi
}

website_local_version() {
	local file=${__CP_WEBSITE__}/ver.info

	if [[ -f ${file} ]]; then
		cat ${file}
	else
		echo zj1.2
	fi
}

website_version() {
	local version=$(website_local_version)
	local target=$(awk -v version=${version} '{if ($1==version) print $2}' ${website_config_file})

	case $(echo ${target} | wc -l) in
	0)
		logger "website" "no found version, needn't upgrade"
		;;
	1)
		logger "website" "need upgrade: ${version}==>${target}"

		echo "${target}"
		;;
	*)
		logger "website" "too more version, don't upgrade"
		;;
	esac
}

website_groups_rsync() {
	local remote=$1; remote=${remote%/}/
	local dir=$2

	if [[ "${__zj_rsync__}" = "no" ]]; then
		local server="lms1.autelan.com"
		local user="autelan"
	else
		local server=${zj_rsync_config_server}
		local user=${zj_rsync_user}
	fi

	local err=0
	rsync_action ${remote} ${dir} ${server} ${user}; err=$?
	echo_logger "website" "$(get_error_tag ${err}): rsync ${remote}"
	if ((0!=err)); then
		return ${err}
	fi
}

save_device_group() {
	local group="$*"
	local group_file=/data/.website_group

	if [[ ${group} ]]; then
		echo "${group}" > ${group_file} 2>/dev/null
	else
		echo "default" > ${group_file} 2>/dev/null
	fi
	fsync ${group_file}
}

get_device_group() {
	local dir_groups="$1"
	local group=""
	local mac=""

	mac=$(cat /data/.register.json 2>/dev/null | jq -j '.mac|strings')
	mac=$(echo ${mac} | tr -s [a-z] [A-Z])
	
	local file
	# Get group_file from dir_groups
	for file in $(ls ${dir_groups}/group_* 2>/dev/null| sort -r); do
		# Get mac's group from group_file
		[[ ${mac} ]] && group=$(awk -v mac=${mac} '{if ($1==mac) print $2}' ${file} 2>/dev/null)
	done
	save_device_group ${group}
	echo ${group}
}

website_groups_config() {
	local group=""
	local config_file=""
	
	# rsync groups' files from remote server
	website_groups_rsync website_groups ${dir_website_groups} || return $?
	if [[ ! -d "${dir_website_groups}" ]]; then
		logger "website" "no found ${dir_website_groups}"
		return
	fi

	# get group from groups
	group=$(get_device_group ${dir_website_groups})

	# get website_config_file for its group
	if [[ ${group} ]] ; then
		website_config_file=${dir_website_config}/website.conf.${group}
	else
		website_config_file=${file_website_config}
	fi
}

website_upgrade() {
	local version="$1"
	
	if [[ -z "${version}" ]]; then
		#
		# get device group and set config file name
		#
		website_groups_config || return $?
		#echo "website_config_file=${website_config_file}"
		
		#
		# get config
		#
		website_config_rsync website_config ${dir_website_config} || return $?
		if [[ ! -f "${website_config_file}" ]]; then
			logger "website" "cannot get ${website_config_file}"
	
			return
		fi
	
		#
		# read config
		#
		version=$(website_version) || return $?
		if [[ -z "${version}" ]]; then
			return
		fi
	fi

	#
	# do upgrade
	#
	#website_rsync /opt/version/lte-fi/website/${version} ${dir_website_upgrade} || return $?
	website_rsync ${version} ${dir_website_upgrade} || return $?
	
	[[ ! -d ${__CP_WEBSITE__} ]] && mkdir -p ${__CP_WEBSITE__}
	mv ${dir_website_upgrade}/ver.info ${__CP_WEBSITE__}/ver.info.bak; sync
	cp -fpR ${dir_website_upgrade}/* ${__CP_WEBSITE__}; sync
	mv ${__CP_WEBSITE__}/ver.info.bak ${__CP_WEBSITE__}/ver.info; sync
}

main() {
	local version="$1"
	local err=0

	sleep 60

	for ((;;)); do
		website_upgrade "${version}" && return

		sleep 300
	done
}

main "$@"

