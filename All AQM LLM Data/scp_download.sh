#!/bin/bash

# Set basic configuration values
set -x


# Access to the source host
srchost="test1"
srchostport="3322"

# Access to the destination host
dsthost="test2"
dsthostport="3323"

# Access to the two dummynet routers
router1port="4422"
router2port="4423"

# Access to VMs and router
src1host="test2"
src1port="3323"
src2host="server"
src2port="4423"
dsthost="client1"
dsthostport="3322"
router1host="dummynetVM1"
router1port="4422"

echo "Script started"

# SSH key
sshkey="mptcprootkey"
sshkeypath="$HOME/.ssh/mptcprootkey"

# Address of VM Host Machine
vmhostaddr="192.168.56.1"

# Set siftr (0 disabled, 1 enabled)
do_siftr="1"

# Set tcpdump (0 disabled, 1 enabled)
do_tcpdump="1"

data_download()
{
    iter=$1
    aqm=$2
    bw=$3
    d=$4
    e=$5
    echo "Starting logging data"
    echo "Iteration: $iter, AQM: $aqm, Bandwidth: $bw, Delay: $d, ECN: $e"
    testname="${iter}_${aqm}_${bw}_${d}_${e}"
    echo "testname: $testname"
    mkdir -p ./server_data
    mkdir -p ./client1_data
    mkdir -p ./client2_data
    mkdir -p ./router_data
    mkdir -p ./Graphs
    mkdir -p ./stats

    scp -P "$dsthostport" -p -i "$sshkeypath" root@"$vmhostaddr":*.siftr.log ./server_data; 
    scp -P "$dsthostport" -p -i "$sshkeypath" root@"$vmhostaddr":*.pcap ./server_data;
    scp -P "$dsthostport" -p -i "$sshkeypath" root@"$vmhostaddr":*.out ./server_data;
    scp -P "$dsthostport" -p -i "$sshkeypath" root@"$vmhostaddr":*.json ./server_data;

    scp -P "$src1port" -p -i "$sshkeypath" root@"$vmhostaddr":*.siftr.log ./client1_data;
    scp -P "$src1port" -p -i "$sshkeypath" root@"$vmhostaddr":*.json ./client1_data;
    scp -P "$src1port" -p -i "$sshkeypath" root@"$vmhostaddr":*.pcap ./client1_data;
    scp -P "$src1port" -p -i "$sshkeypath" root@"$vmhostaddr":*.out ./client1_data;:
    scp -P "$src2port" -p -i "$sshkeypath" root@"$vmhostaddr":*.siftr.log ./client2_data;
    scp -P "$src2port" -p -i "$sshkeypath" root@"$vmhostaddr":*.json ./client2_data;
    scp -P "$src2port" -p -i "$sshkeypath" root@"$vmhostaddr":*.pcap ./client2_data;
    scp -P "$src2port" -p -i "$sshkeypath" root@"$vmhostaddr":*.out ./client2_data;

    ssh -p "$router1port" -i "$sshkeypath" root@"$vmhostaddr" "cat /var/log/messages > kernel_data_{$testname}.txt"

    scp -P "$router1port" -p -i "$sshkeypath" root@"$vmhostaddr":*txt ./router_data; 
}






data_download "1" "l4s" "10Mbps" "10ms" "ecn"

end_log
# completed
echo "Reset complete"
exit 0

# error
out() {
    echo "Abort test"
    exit 1
}