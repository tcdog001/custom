#!/bin/sh
echo "setup.sh running!"

export PATH=.:$PATH
if [ -z "$HN_SCRIPT" ]
then
        HN_SCRIPT=/data/zjhn/script
        export HN_SCRIPT
fi

cd $HN_SCRIPT
./01_check_update.sh

exit 0
