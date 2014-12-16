#!/bin/bash

main() {
        arp -i eth0.1 >/tmp/tftp/usr_arp.log
}

main "$@"