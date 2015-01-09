#!/bin/bash

readonly dir_usb=/mnt/usb
readonly dir_usb_upgrade=${dir_usb}/upgrade
readonly dir_usb_backup=${dir_usb}/backup

readonly dir_tftp=/tmp/tftp
readonly file_ap=sysupgrade.bin
readonly file_ap_long=openwrt-ar71xx-generic-db120-squashfs-sysupgrade.bin

#
#$1:action
#	upgrade/backup
#
dir_usb_base() {
	local action=$1

	echo ${dir_usb}/${action}
}

#
#$1:action
#	upgrade/backup
#
dir_usb_rootfs_data() {
	local action=$1

	echo $(dir_usb_base ${action})/rootfs_data
}

#
#$1:action
#	upgrade/backup
#
dir_usb_rootfs() {
	local action=$1

	echo $(dir_usb_base ${action})/rootfs
}

readonly dir_rootfs_data=/data
#
#$1:rootfs idx
#
dir_rootfs() {
	local idx=$1

	echo /rootfs${idx}
}

readonly dev_usb=/dev/sdb1

declare -A dev_emmc_bin=(
	[fastboot-burn.bin]=/dev/mmcblk0p1
	[pq_param_hi3718cv100.bin]=/dev/mmcblk0p4
	[hi_kernel.bin]=/dev/mmcblk0p6
)

readonly dev_rootfs0=/dev/mmcblk0p7
readonly dev_rootfs1=/dev/mmcblk0p8
readonly dev_rootfs2=/dev/mmcblk0p9

#
#$1:src
#$2:dst
#
CP_DIR() {
	local src=$1
	local dst=$2
	local err=0
	local tag

	rm -fr ${dst}/*
	cp -fpR ${src}/* ${dst}; err=$?

	local tag
	if [ "0" != "${err}" ]; then
		tag="ERROR[${err}]"
	else
		tag="OK"
	fi
	echo "${tag}: copy ${src} to ${dst}"

	return ${err}
}

#
#$1:action
#$2:partition
#$3:file
#
DD() {
	local action=$1
	local partition=$2
	local file=$3
	local op
	local err=0

	case "${action}" in
	"upgrade")
		op="by"

		if [ -f "${file}" ]; then
			dd if=${file} of=${partition} > /dev/null 2>&1; err=$?
		fi
		;;
	"backup")
		op="to"

		rm -f ${file}

		dd if=${partition} of=${file} > /dev/null 2>&1; err=$?
		;;
	*)
		return ${e_inval}
		;;
	esac

	local tag
	if [ "0" != "${err}" ]; then
		tag="ERROR[${err}]"
	else
		tag="OK"
	fi
	echo "${tag}: ${action} ${partition} ${op} ${file}"

	return ${err}
}

#
# get current rootfs's idx
#
rootfs_current() {
	local self=$(cat /proc/cmdline | sed 's# #\n#g' | grep root= | awk -F '=' '{print $2}')
	local i

	for ((i=0; i<=2; i++)); do
		local dev=dev_rootfs${i}

		if [ "${!dev}" == "${self}" ]; then
			echo "${i}"

			return
		fi
	done

	echo "0"
	return ${e_noexist}
}

#
#$1:target
#
usb_upgrade() {
	local target=$1
	local current=$(rootfs_current)
	local partition
	local file
	local name
	local err=0
	local failed=0
	local tag
	local src
	local dst

	case "${target}" in
	"bin")
		for name in ${!dev_emmc_bin[*]}; do
			file=${dir_usb_upgrade}/${name}
			partition=${dev_emmc_bin[${name}]}

			DD upgrade ${partition} ${file}; err=$?
			if [ "0" != "${err}" ]; then
				failed=${err}
			fi
		done

		sync

		return ${failed}
		;;
	"data")
		src=$(dir_usb_rootfs_data upgrade)
		dst=${dir_rootfs_data}
		if [ -d "${src}" ]; then
			CP_DIR ${src} ${dst}; err=$?; sync

			return ${err}
		fi
		;;
	"ap")
		rm -f ${dir_tftp}/${file_ap_long}
		ln -sf /rootfs0/image/${file_ap} ${dir_tftp}/${file_ap_long}; sync
		return
		;;
	esac

	#
	# rootfs 0/1/2
	#
	src=$(dir_usb_rootfs upgrade)
	dst=$(dir_rootfs ${target})

	if [[ -d "${src}" && "${target}" != "${current}" ]]; then
		if ((0==target)); then
			umount ${dst}
			mount -t ext4 ${dev_rootfs0} ${dst}
		fi

		CP_DIR ${src} ${dst}; err=$?; sync

		return ${err}
	fi
}


#
#$1:target
#
usb_backup() {
	local target=$1
	local current=$(rootfs_current)
	local partition
	local file
	local name
	local err=0
	local failed=0
	local tag
	local src
	local dst

	case "${target}" in
	"bin")
		for name in ${!dev_emmc_bin[*]}; do
			file=${dir_usb_backup}/${name}
			partition=${dev_emmc_bin[${name}]}

			DD backup ${partition} ${file}; err=$?
			if [ "0" != "${err}" ]; then
				failed=${err}
			fi
		done

		sync

		return ${failed}
		;;
	"data")
		echo "no support backup rootfs data"

		return
		;;
	"data")
		echo "no support backup ap"

		return
		;;
	esac

	src=$(dir_rootfs ${target})
	dst=$(dir_usb_rootfs backup)
	if ((target!=current)); then
		CP_DIR ${src} ${dst}; err=$?; sync

		return ${err}
	fi
}

usb_backup_to_upgrade() {
	local err=0

	rm -fr ${dir_usb_upgrade}/*
	cp -fpR ${dir_usb_backup}/* ${dir_usb_upgrade}; err=$?; sync

	local tag
	if [ "0" != "${err}" ]; then
		tag="ERROR[${err}]"
	else
		tag="OK"
	fi
	echo "${tag}: copy ${dir_usb_backup} to ${dir_usb_upgrade}"

	return ${err}
}

setup_usb_dir() {
	mkdir -p ${dir_usb_backup}/rootfs_data
	mkdir -p ${dir_usb_backup}/rootfs

	mkdir -p ${dir_usb_upgrade}/rootfs_data
	mkdir -p ${dir_usb_upgrade}/rootfs
}

mount_usb () {
	mkdir -p ${dir_usb}

	if [ -z "$(cat /proc/partitions | grep $(basename ${dev_usb}))" ]; then
		#
		# if dev no exist, exit
		#
		echo "usb not exist"

		return ${e_noexist}
	elif [ -n "$(mount | grep ${dev_usb})" ]; then
		#
		# if have mounted, do nothing
		#
		setup_usb_dir
	else
		mount -t ext4 ${dev_usb} ${dir_usb} > /dev/null 2>&1 && {
			setup_usb_dir
		}
	fi
}

usage() {
	echo "$0 upgrade 0/1/2/bin/data/ap"
	echo
}

check() {
	local argc=$#
	local action=$1
	local target=$2
	local target_check

	if ((argc>2 || argc<1)); then
		usage

		exit ${e_inval}
	fi

	case "${action}" in
	"upgrade")
		target_check=on
		;;
	"backup")
		target_check=on
		;;
	"backup_to_upgrade")
		;;
	*)
		usage

		exit ${e_inval}
		;;
	esac

	if [ -n "${target_check}" ]; then
		case "${target}" in
		"0")
			;;
		"1")
			;;
		"2")
			;;
		"bin")
			;;
		"data")
			;;
		"ap")
			;;
		*)
			usage

			exit ${e_inval}
			;;
		esac
	fi
}

#
#$1:action 0/1/2
#$2:target
#
main() {
	local action=$1
	local target=$2
	check "$@"

	mount_usb || {
		return
	}

	local err=0
	usb_${action} ${target}; err=$?

	return ${err}
}

main "$@"
