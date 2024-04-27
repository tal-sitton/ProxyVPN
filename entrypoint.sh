#! /bin/bash
sysctl net.ipv6.conf.all.disable_ipv6=0
# create tun device
mkdir -p /dev/net
mknod /dev/net/tun c 10 200
chmod 600 /dev/net/tun

# start vpn service and check script exit code
if ! ./vpn.sh; then
  echo "Failed to connect to VPN"
  exit 1
fi

#start privoxy service
privoxy --no-daemon /etc/privoxy/config