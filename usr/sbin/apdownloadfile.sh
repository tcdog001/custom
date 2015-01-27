#!/bin/bash

#
#$1:mdfile
#$2:apfile
#
main() {
	local mdfile="$1"
	local apfile="$2"
	local file=$(basename ${mdfile})
	local tftpfile=${dir_tftp}/${file}

	cp -f ${mdfile} ${tftpfile}; fsync ${tftpfile}
	${__ROOTFS__}/etc/jsock/jcmd.sh syn "tftp -g -l ${apfile} -r ${file}" &
}

main "$@"
