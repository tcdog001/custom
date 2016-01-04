#!/bin/bash

ipset -N white_list ipmap --network 192.168.0.0/16
ipset -N dst_white hash:ip --hashsize 1024
ipset -A dst_white 120.27.136.216 
ipset -A dst_white 120.27.137.55 
ipset -A dst_white 120.27.136.232 
ipset -A dst_white 120.27.137.12 
ipset -A dst_white 120.27.136.229 
ipset -A dst_white 120.27.137.22 
ipset -A dst_white 120.27.137.26 
ipset -A dst_white 120.27.137.44 
ipset -A dst_white 120.55.245.7 
ipset -A dst_white 112.124.121.173 

iptables -t nat -A PREROUTING  -i eth0.1  -m set --match-set dst_white dst  -j ACCEPT
iptables -t nat -A PREROUTING  -i eth0    -m set --match-set dst_white src  -j ACCEPT

iptables -t nat -A PREROUTING  -i eth0.1  -d 192.168.0.1  -j ACCEPT

iptables -t nat -A PREROUTING  -i eth0.1  -p tcp -j REDIRECT --to-port 3127
