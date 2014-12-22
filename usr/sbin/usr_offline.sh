#!/bin/bash

main() {
        iptables -t mangle -F WiFiDog_eth0.1_Trusted
}
main "$@"