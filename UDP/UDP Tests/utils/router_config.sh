#!/bin/bash

# Function to configure TCP CC and ECN on Source
configure_tcp_cc_ecn() {
    ecn_status=$1
    echo "Configuring TCP CC and ECN on sources"
    ssh -p "$src1port" -i "$sshkeypath" root@"$vmhostaddr" "kldload cc_$tcp1"
    ssh -p "$src1port" -i "$sshkeypath" root@"$vmhostaddr" "sysctl net.inet.tcp.cc.algorithm=$tcp1"
    ssh -p "$src2port" -i "$sshkeypath" root@"$vmhostaddr" "kldload cc_$tcp2"
    ssh -p "$src2port" -i "$sshkeypath" root@"$vmhostaddr" "sysctl net.inet.tcp.cc.algorithm=$tcp2"

    # Set DCTCP ECT1
    if [ "$tcp1" == "dctcp" ]; then
        ssh -p "$src1port" -i "$sshkeypath" root@"$vmhostaddr" "sysctl net.inet.tcp.cc.dctcp.ect1=$dctcp_ect1"
    fi

    if [ "$tcp2" == "dctcp" ]; then
        ssh -p "$src2port" -i "$sshkeypath" root@"$vmhostaddr" "sysctl net.inet.tcp.cc.dctcp.ect1=$dctcp_ect1"
    fi

    # Set ECN enable
    if [ "$ecn_status" == "ecn" ]; then
        ssh -p "$src1port" -i "$sshkeypath" root@"$vmhostaddr" "sysctl net.inet.tcp.ecn.enable=$tcp_ecn_enable"
        ssh -p "$src2port" -i "$sshkeypath" root@"$vmhostaddr" "sysctl net.inet.tcp.ecn.enable=$tcp_ecn_enable"
        ssh -p "$router1port" -i "$sshkeypath" root@"$vmhostaddr" "sysctl net.inet.tcp.ecn.enable=$tcp_ecn_enable"
    elif [ "$ecn_status" == "noecn" ]; then
        ssh -p "$src1port" -i "$sshkeypath" root@"$vmhostaddr" "sysctl net.inet.tcp.ecn.enable=0"
        ssh -p "$src2port" -i "$sshkeypath" root@"$vmhostaddr" "sysctl net.inet.tcp.ecn.enable=0"
        ssh -p "$router1port" -i "$sshkeypath" root@"$vmhostaddr" "sysctl net.inet.tcp.ecn.enable=0"
    fi
}

# Function to configure AQM on routers
configure_routers() {
    aqm=$1
    bw=$2
    d=$3
    e=$4
    echo "Configuring AQM: $aqm with bandwidth $bw and delay $d, ECN: $e"
    ssh -p "$router1port" -i "$sshkeypath" root@"$vmhostaddr" "ipfw -f flush"
    ssh -p "$router1port" -i "$sshkeypath" root@"$vmhostaddr" "ipfw pipe 1 config bw $bw delay $d"
    ssh -p "$router1port" -i "$sshkeypath" root@"$vmhostaddr" "ipfw sched 1 config pipe 1 type $aqm $e"
    ssh -p "$router1port" -i "$sshkeypath" root@"$vmhostaddr" "ipfw queue 1 config sched 1"
    ssh -p "$router1port" -i "$sshkeypath" root@"$vmhostaddr" "ipfw add 100 queue 1 ip from any to any"
}