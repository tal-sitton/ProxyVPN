#! /bin/bash

paste_keys=("G6ndA3Rs" "NJCpNsUH" "NfF1QMiL" "bR4A6BhY" "y1hMn7Xa" "SxRkCK9t")

my_ip=$(curl -s ifconfig.me)

# function to get ovpn files from pastebin
get_ovpn_files() {
  mkdir -p openvpns
  for key in "${paste_keys[@]}"; do
    curl -X POST -d "api_dev_key=$PASTE_DEV_KEY" -d "api_user_key=$PASTE_USER_KEY" -d "api_option=show_paste" -d "api_paste_key=$key" "https://pastebin.com/api/api_post.php" > "openvpns/$key.ovpn"
  done
}

# function to try to connect to vpn and check if it fails
connect_vpn() {
  for key in "${paste_keys[@]}"; do
    openvpn --config "openvpns/$key.ovpn" --daemon
    sleep 10
    if [[ $(curl -s ifconfig.me) != "$my_ip" ]]; then
      echo "Connected to VPN $key successfully: $(curl -s ifconfig.me)"
      break
    else
      echo "Failed to connect to VPN $key, ip is still $my_ip"
      killall openvpn
    fi
  done
}

get_ovpn_files
connect_vpn
