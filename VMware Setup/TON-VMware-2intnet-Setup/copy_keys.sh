#!/bin/bash
#
# Copy the public and private keys across to all the testbed hosts using IP addresses.
# Assumes that NAT forwarding has been configured and each of the VMs is running.
#  
# This _should_ be run on the controller host, but will work if run from elsewhere. 

set -x

# The user on the controller that will execute the test scripts
controlleruser="deolubuntu"

keypath="keys"

client1_ipaddr="192.168.11.130"
client2_ipaddr="192.168.11.131"
router_ipaddr="192.168.11.128"
server_ipaddr="192.168.11.132"

# Function to configure SSH keys on the controller host
# Arguments: controller IP address, controller username
configure_controller_ssh_key() {
    local controller=$1
    local user=$2
    local keypath=$3
    echo "create .ssh folder"
    ssh root@$controller 'mkdir .ssh/'
    echo "Copying root public key to host at $controller"
    scp -o StrictHostKeyChecking=no -p -i ~/.ssh/mptcprootkey $keypath/mptcprootkey.pub root@${controller}:/root/.ssh/authorized_keys
    echo "set authorized keys permissions to 644"
    ssh root@$controller 'chmod 644 .ssh/authorized_keys'    
    echo "Copying root private key to host at $controller"
    scp -p -i ~/.ssh/mptcprootkey ~/.ssh/mptcprootkey root@${controller}:/root/.ssh/
}



# Configure keys on router
configure_controller_ssh_key "$router_ipaddr" "root" "$keypath"

# Configure keys on client1
configure_controller_ssh_key "$client1_ipaddr" "root" "$keypath"

# Configure keys on client2
configure_controller_ssh_key "$client2_ipaddr" "root" "$keypath"

# Configure keys on server
configure_controller_ssh_key "$server_ipaddr" "root" "$keypath"

exit 0
