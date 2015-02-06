#!/bin/bash

. ${__ROOTFS__}/etc/upgrade/dir.in

readonly -A deft_website=(
	[server]=lms9.autelan.com
	[port]=873
	[user]=rsync
	[pass]=ltefi@Autelan1
	[remote]=/opt/version/lte-fi/website
	[timeout]=300
)

declare json_website

#
#$1:info
#
website_logger() {
	do_logger website "$@"
}

#
#$1:info
#
website_echo_logger() {
	echo_logger website "$@"
}

#
#$1:local version
#$2:config
#
website_upgrade_version() {
	local version="$1"
	local config="$2"

	local target=$(awk -v version=${version} '{if ($1==version) print $2}' ${config})
	local count=$(echo ${target} | wc -l)

	if [[ -z "${target}" || "0" == "${count}" ]]; then
		website_logger "no found version, needn't upgrade"
	elif ((1==count)); then
		website_logger "need upgrade: ${version}==>${target}"

		echo "${target}"
	else
		website_logger "too more version, don't upgrade"
	fi
}

#
#$1:remote dir/file
#$2:local  dir/file
#$3:aa
#
website_rsync() {
	local remote="$1"; remote=${remote%/}/
	local dir="$2"
	local website="$3"

	local server="$(aa_get ${website} server)"
	local port="$(aa_get ${website} port)"
	local user="$(aa_get ${website} user)"
	local pass="$(aa_get ${website} pass)"
	local timeout="$(aa_get ${website} timeout)"

	local sshparam="sshpass -p ${pass} ssh -l ${user} -o StrictHostKeyChecking=no"
	local rsync_dynamic="--rsh=\"${sshparam}\" --timeout=${timeout}"
	local rsync_static="-acz --delete --force --stats --partial"

	local err=0
	local action="rsync ${rsync_dynamic} ${rsync_static} ${server}:${remote} ${dir}"
	eval "${action}"; err=$?
	website_echo_logger "$(get_error_tag ${err}): rsync ${remote}"

	return ${err}
}

website_upgrade() {
	local website="$1"
	local remote="$(aa_get ${website} remote)"

	#
	# get config
	#
	website_rsync ${remote}/website_config ${dir_website_config} ${website} || return $?
	if [[ ! -f "${file_website_config}" ]]; then
		website_logger "no found ${file_website_config}"

		return
	fi

	#
	# read config
	#
	dos2unit ${file_website_config}
	local version=$(website_upgrade_version \
						$(< ${__CP_WEBSITE__}/ver.info) \
						${file_website_config}) || return $?
	if [[ -z "${version}" ]]; then
		website_logger "needn't upgrade"

		return
	fi

	#
	# do upgrade
	#
	website_rsync ${remote}/${version} ${dir_website_upgrade} ${website} || return $?
	cp -fpR ${dir_website_upgrade} ${__CP_WEBSITE__}; sync
}

main() {
	local deft=/etc/upgrade/config/website.json
	local config=${dir_config_upgrade}/website.json

	if [[ ! -f "${config}" ]]; then
		cp -f ${deft} ${config}
	fi

	local -A website
	json_to_aa_with_deft deft_website website "$(cat ${config})"

	for ((;;)); do
		sleep 600

		website_upgrade website && return
	done
}

main "$@"
