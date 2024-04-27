#! /bin/bash

# create tun device
mkdir -p /dev/net
mknod /dev/net/tun c 10 200
chmod 600 /dev/net/tun

# start vpn service
./vpn.sh

#start privoxy service
privoxy --no-daemon /etc/privoxy/config