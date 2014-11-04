#!/bin/sh

/etc/jsock/msg/getsysinfo.sh 

. /etc/platform/bin/platform.in

file_json=$FILE_REGISTER

devicesn=`cat $file_json |awk -F ',' '{print $3}'`
deviceCompany=`cat $file_json |awk -F ',' '{print $1}' |sed '1s/.//1'`
deviceModel=`cat $file_json |awk -F ',' '{print $2}'`
Mac=`cat $file_json |awk -F ',' '{print $4}'`
MEID_3g=`cat $file_json |awk -F ',' '{print $17}'` 2>/dev/null
snOf3g=`cat $file_json |awk -F ',' '{print $20}'`
Company_3g=`cat $file_json |awk -F ',' '{print $18}'`
modelOf3g=`cat $file_json |awk -F ',' '{print $19}'`
Operators=`cat $file_json |awk -F ',' '{print $22}'`
iccid=`cat $file_json |awk -F ',' '{print $21}'`
firmwareVersion=`cat $file_json |awk -F ',' '{print $24}'`
hardVersion=`cat $file_json |awk -F ',' '{print $23}'`
diskSN=`cat $file_json |awk -F ',' '{print $26}'`
diskModel=`cat $file_json |awk -F ',' '{print $25}'`
gatewayVersion=`cat $file_json |awk -F ',' '{print $27}'`
contentVersion=`cat $file_json |awk -F ',' '{print $28}'`

echo $devicesn
echo $deviceCompany
echo $deviceModel
echo $Mac
echo $MEID_3g
echo $snOf3g
echo $Company_3g
echo $modelOf3g
echo $Operators
echo $iccid
echo $firmwareVersion
echo $hardVersion
#echo $media_info
echo $diskSN
echo $diskModel
echo $gatewayVersion
echo $contentVersion
