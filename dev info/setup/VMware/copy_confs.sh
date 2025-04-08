#!/bin/bash

set -x
# Define IP addresses
client1_ipaddr="192.168.11.130"
client2_ipaddr="192.168.11.131"
router_ipaddr="192.168.11.128"
server_ipaddr="192.168.11.132"

# Define SSH private key
SSH_KEY="~/.ssh/mptcprootkey"

# Function to copy config files
copy_config_files() {
  local ip=$1
  local config_dir=$2

  scp -p -i "$SSH_KEY" "$config_dir/rc.conf" root@"$ip":/etc/
  scp -p -i "$SSH_KEY" "$config_dir/ipfw.rules" root@"$ip":/etc/
  scp -p -i "$SSH_KEY" "$config_dir/loader.conf" root@"$ip":/boot/
}

# Copy config files for the server
copy_config_files "$server_ipaddr" "confs/server"

# Copy config files for client 1
copy_config_files "$client1_ipaddr" "confs/client1"

# Copy config files for router
copy_config_files "$router_ipaddr" "confs/router"

# Copy config files for client 2
copy_config_files "$client2_ipaddr" "confs/client2"

# Output completion message
echo "Configuration files copied successfully."

exit 0
