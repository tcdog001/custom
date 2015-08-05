#!/bin/bash

iptables -F FORWARD
iptables -P  FORWARD ACCEPT
iptables -t nat -F PREROUTING
ipset -F white_list
