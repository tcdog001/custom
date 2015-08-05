<?php
$ip = $_SERVER['REMOTE_ADDR'];
$mac = getMac($ip);
$markver1="1.1.1.0";
enable_address($mac);

//页面的异步提交，返回
echo json_encode( array( 'code' => 'ok'));
exit();

/**
  功能：根据IP地址，从设备中读取MAC地址列表，并过滤出认证用户的MAC
  参数：IP地址
 **/
function getMac($ip)
{
	$mac = shell_exec("sudo /sbin/arp ".$ip);
	preg_match('/..:..:..:..:..:../',$mac , $matches);
	@$mac = $matches[0];
	if (!isset($mac)) {
		return;
	}else {
		return $mac;
	}
}
/*
  功能：比较/etc/.version中的版本号与tempver的大小。当大于markver1时返回1，小于等于markver1时返回0.
  参数:版本号字符串
*/
function vercmp()
{
	global $markver1;
	$file_handle = fopen("/etc/.version", "r");
	$version = fgets($file_handle);
	$version = trim($version, " \n\r");
	fclose($file_handle);

	if(strcmp($version,$markver1) > 0)
		return 1;
	else 
		return 0;
}
/**
  功能：调用系统中（iwpriv wifi0_wlan0 set_auth_mac 参数）命令，将mac地址添加到可以上网认证列表中，实现用户上网功能
  参数：mac地址
  注意事项:改命令，只能执行一次，如果已经认证mac地址，再认证时，会报错

 **/
function enable_address($mac) {
	if(vercmp() > 0){
		$shell = "sudo /usr/sbin/userauth 1 $mac";
		exec($shell, $res);
	}
	else{
		if(file_exists("/data/app/etc/um/usr_certificate.sh")){
 			$shell = "sudo /data/app/etc/um/usr_certificate.sh $mac & ";
			exec($shell, $res);
		}
		else{
			$shell = "sudo /sbin/iptables -t mangle -A WiFiDog_eth0.1_Trusted -m mac --mac-source ${mac} -j MARK --set-mark 2";
			exec($shell, $res);
		}
	}
}

