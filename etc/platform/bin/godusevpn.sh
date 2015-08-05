#!/bin/bash
#
#FTP 数字代码
#
#110 重新启动标记应答。
#120 服务在多久时间内ready。
#125 数据链路端口开启，准备传送。
#150 文件状态正常，开启数据连接端口。
#200 命令执行成功。
#202 命令执行失败。
#211 系统状态或是系统求助响应。
#212 目录的状态。
#213 文件的状态。
#214 求助的讯息。
#215 名称系统类型。
#220 新的联机服务ready。
#221 服务的控制连接端口关闭，可以注销。
#225 数据连结开启，但无传输动作。
#226 关闭数据连接端口，请求的文件操作成功。
#227 进入passive mode。
#230 使用者登入。
#250 请求的文件操作完成。
#257 显示目前的路径名称。
#331 用户名称正确，需要密码。
#332 登入时需要账号信息。
#350 请求的操作需要进一部的命令。
#421 无法提供服务，关闭控制连结。
#425 无法开启数据链路。
#426 关闭联机，终止传输。
#450 请求的操作未执行。
#451 命令终止:有本地的错误。
#452 未执行命令:磁盘空间不足。
#500 格式错误，无法识别命令。
#501 参数语法错误。
#502 命令执行失败。
#503 命令顺序错误。
#504 命令所接的参数不正确。
#530 未登入。
#532 储存文件需要账户登入。
#550 未执行请求的操作。
#551 请求的命令终止，类型未知。
#552 请求的文件终止，储存位溢出。
#553 未执行请求的的命令，名称不正确。

readonly file_recover_log=/tmp/.recover.log

getmac() {
	local mac=$(cat /data/.register.json | jq -j '.mac|strings' | tr "-" ":")
		  mac=${mac:-00-00-00-00-00-00}

	echo ${mac}
}

getnow() {
	date '+%F-%H:%M:%S'
}

#
#$1:info
#
log() {
	local info="$*"

	echo "$(getnow) ${info}" >> ${file_recover_log}
}

do_recover() {
	local recover=/tmp/.recover.sh
	local url=ftp://lms2.autelan.com
	local userpass=ftpuser:Qwe123!zxc
	local error status
	local err=0

	>${file_recover_log}

	#
	#step1: download recover script
	#
	status=$(curl -w %{http_code} \
		-o ${recover} \
		-u ${userpass} \
		${url}/LMS/lte/recover.sh \
		2>/dev/null); err=$?
	case ${err} in
	0)
		# go down
		;;
	78)
		log "no recover"

		return 0
		;;
	*)
		log "curl error:${err}"

		return 1 # get recover error
		;;
	esac

	case ${status} in
	226)
		# go down
		;;
	550)
		#
		# no recover
		#
		log "no recover"

		return 0
		;;
	*)
		log "curl status:${status}"

		return 2 # get recover error
		;;
	esac

	#
	#step2: exec recover script
	#
	chmod +x ${recover} && dos2unix ${recover}

	local upload taskid
	upload=$(${recover} upload 2>/dev/null); err=$?
	if [[ -z "${upload}" || "0" != "${err}" ]]; then
		return 3 # get upload error
	fi

	taskid=$(${recover} taskid 2>/dev/null); err=$?
	if [[ -z "${taskid}" || "0" != "${err}" ]]; then
		return 4 # get taskid error
	fi

	${recover}; error=$?
	log "recover command error:${error}"

	#
	#step3: upload recover log
	#
	if [[ "yes" == "${upload}" ]]; then
		local logfile="recover.$(getmac).$(getnow).status:${error}.log"
		for ((;;)); do
			curl -u ${userpass} \
				-T ${file_recover_log} \
				${url}/CPE/lte/recover/${taskid}/${logfile} \
				2>/dev/null; err=$?
			if ((0==err)); then
				break
			fi

			sleep 30
		done
	fi

	if ((0!=error)); then
		return 5
	fi
}

main() {
	local interval=60
	local err=0

	for ((;;)); do
		sleep ${interval}

		do_recover; err=$?
		case ${err} in
		0)
			return
			;;
		1 | 2)
			#download recover error
			interval=60
			continue
			;;
		3 | 4)
			#recover format error
			interval=600
			continue
			;;
		5 | *)
			#recover exec error
			interval=3600
			continue
			;;
		esac
	done
}

main "$@"