#!/bin/sh
echo "init running!"

export PATH=.:$PATH

if [ -z "$HN_SCRIPT" ]
then
	HN_SCRIPT=/data/zjhn/script
	export HN_SCRIPT
fi

cd $HN_SCRIPT
./setup.sh

exit 0
