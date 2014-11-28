#!/bin/bash

. ${__ROOTFS__}/etc/upgrade/dir.in

#
#$1:remote
#$2:dir
#
website_rsync() {
	local remote=$1; remote=${remote%/}/
	local dir=$2

	local port="873"
	local server="atbus.autelan.com"
	local user="root"
	local pass="ltefi@Autelan1"
	local timeout="300"

	local sshparam="sshpass -p ${pass} ssh -l ${user} -o StrictHostKeyChecking=no"
	local rsync_dynamic="--rsh=\"${sshparam}\" --timeout=${timeout}"
	local rsync_static="-acz --delete --force --stats --partial"
	local action="rsync ${rsync_dynamic} ${rsync_static} ${server}:${remote} ${dir}"

	local err=0
	eval "${action}"; err=$?
	echo_logger "website" "$(get_error_tag ${err}): rsync ${remote}"
	if ((0!=err)); then
		return ${err}
	fi
}

website_local_version() {
	local file=${dir_website}/ver.info

	if [[ -f ${file} ]]; then
		cat ${file}
	else
		echo zj1.2
	fi
}

website_version() {
	local version=$(website_local_version)
	local target=$(awk -v version=${version} '{if ($1==version) print $2}' ${file_website_config})
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

website_upgrade() {
	#
	# get config
	#
	website_rsync /opt/version/lte-fi/website/website_config ${dir_website_config} || return $?
	if [[ ! -f "${file_website_config}" ]]; then
		logger "website" "no found ${file_website_config}"

		return
	fi

	#
	# read config
	#
	local version=$(website_version) || return $?
	if [[ -z "${version}" ]]; then
		return
	fi

	#
	# do upgrade
	#
	website_rsync /opt/version/lte-fi/website/${version} ${dir_website_upgrade} || return $?
	cp -fpR ${dir_website_upgrade}/* ${dir_website}; sync
}

main() {
	local err=0

	sleep 60

	for ((;;)); do
		website_upgrade && return

		sleep 300
	done
}

main "$@"

