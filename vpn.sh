#! /bin/bash

# shellcheck disable=SC2206
paste_keys=($PASTE_KEYS)

my_ip=$(curl -s ifconfig.me)

# function to get ovpn files from pastebin
get_ovpn_files() {
  mkdir -p openvpns
  for key in "${paste_keys[@]}"; do
    curl -X POST -d "api_dev_key=$PASTE_DEV_KEY" -d "api_user_key=$PASTE_USER_KEY" -d "api_option=show_paste" -d "api_paste_key=$key" "https://pastebin.com/api/api_post.php" > "openvpns/$key.ovpn"
    #check if file is valid
    if grep -q "Bad API request" "openvpns/$key.ovpn"; then
      echo "Failed to get ovpn file for $key"
      exit 1
    fi
  done
}

# function to try to connect to vpn and check if it fails
connect_vpn() {
  while [ ${#paste_keys[@]} -gt 0 ]; do
    key=${paste_keys[$RANDOM % ${#paste_keys[@]}]}
    openvpn --config "openvpns/$key.ovpn" --daemon
    sleep 10
    if [[ $(curl -s ifconfig.me) != "$my_ip" ]]; then
      echo "Connected to VPN $key successfully: $(curl -s ifconfig.me)"
      return 0
    else
      echo "Failed to connect to VPN $key, ip is still $my_ip"
      killall openvpn
    fi
    paste_keys=(${paste_keys[@]/$key})
  done
  exit 1
}

get_ovpn_files
connect_vpn
