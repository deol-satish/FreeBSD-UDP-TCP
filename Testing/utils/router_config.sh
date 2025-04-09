#!/bin/bash

# Function to configure TCP CC and ECN on Source
configure_tcp_cc_ecn() {
    ecn_status=$1
    echo "Configuring TCP CC and ECN on sources"
    ssh -i ~/.ssh/mptcprootkey root@$client1_ipaddr "kldload cc_$tcp1"
    ssh -i ~/.ssh/mptcprootkey root@$client1_ipaddr "sysctl net.inet.tcp.cc.algorithm=$tcp1"
    ssh -i ~/.ssh/mptcprootkey root@$client2_ipaddr "kldload cc_$tcp2"
    ssh -i ~/.ssh/mptcprootkey root@$client2_ipaddr "sysctl net.inet.tcp.cc.algorithm=$tcp2"

    # Set ECN enable
    if [ "$ecn_status" == "ecn" ]; then
        ssh -i ~/.ssh/mptcprootkey root@$client1_ipaddr "sysctl net.inet.tcp.ecn.enable=$tcp_ecn_enable"
        ssh -i ~/.ssh/mptcprootkey root@$client2_ipaddr "sysctl net.inet.tcp.ecn.enable=$tcp_ecn_enable"
        ssh -i ~/.ssh/mptcprootkey root@$router_ipaddr "sysctl net.inet.tcp.ecn.enable=$tcp_ecn_enable"
        ssh -i ~/.ssh/mptcprootkey root@$server_ipaddr "sysctl net.inet.tcp.ecn.enable=$tcp_ecn_enable"
    elif [ "$ecn_status" == "noecn" ]; then
        ssh -i ~/.ssh/mptcprootkey root@$client1_ipaddr "sysctl net.inet.tcp.ecn.enable=0"
        ssh -i ~/.ssh/mptcprootkey root@$client2_ipaddr "sysctl net.inet.tcp.ecn.enable=0"
        ssh -i ~/.ssh/mptcprootkey root@$router_ipaddr "sysctl net.inet.tcp.ecn.enable=0"
        ssh -i ~/.ssh/mptcprootkey root@$server_ipaddr "sysctl net.inet.tcp.ecn.enable=0"
    fi

    # Set DCTCP ECT1
    if [ "$tcp1" == "dctcp" ]; then
        if [ "$ecn_status" == "ecn" ]; then
            ssh -i ~/.ssh/mptcprootkey root@$router_ipaddr "sysctl net.inet.tcp.ecn.enable=3"
            ssh -i ~/.ssh/mptcprootkey root@$client1_ipaddr "sysctl net.inet.tcp.ecn.enable=3"
            ssh -i ~/.ssh/mptcprootkey root@$client2_ipaddr "sysctl net.inet.tcp.ecn.enable=3"
            ssh -i ~/.ssh/mptcprootkey root@$server_ipaddr "sysctl net.inet.tcp.ecn.enable=3"
        fi
        ssh -i ~/.ssh/mptcprootkey root@$client1_ipaddr "sysctl net.inet.tcp.cc.dctcp.ect1=$dctcp_ect1"
    fi

    if [ "$tcp2" == "dctcp" ]; then
        if [ "$ecn_status" == "ecn" ]; then
            ssh -i ~/.ssh/mptcprootkey root@$router_ipaddr "sysctl net.inet.tcp.ecn.enable=3"
            ssh -i ~/.ssh/mptcprootkey root@$client1_ipaddr "sysctl net.inet.tcp.ecn.enable=3"
            ssh -i ~/.ssh/mptcprootkey root@$client2_ipaddr "sysctl net.inet.tcp.ecn.enable=3"
            ssh -i ~/.ssh/mptcprootkey root@$server_ipaddr "sysctl net.inet.tcp.ecn.enable=3"
        fi        
        ssh -i ~/.ssh/mptcprootkey root@$client2_ipaddr "sysctl net.inet.tcp.cc.dctcp.ect1=$dctcp_ect1"
    fi


}

# Function to configure AQM on routers
configure_routers() {
    aqm=$1
    bw=$2
    d=$3
    e=$4
    echo "Configuring AQM: $aqm with bandwidth $bw and delay $d, ECN: $e"
    ssh -i ~/.ssh/mptcprootkey root@$router_ipaddr "ipfw -f flush"
    ssh -i ~/.ssh/mptcprootkey root@$router_ipaddr "ipfw pipe 1 config bw $bw delay $d"
    ssh -i ~/.ssh/mptcprootkey root@$router_ipaddr "ipfw sched 1 config pipe 1 type $aqm $e"
    ssh -i ~/.ssh/mptcprootkey root@$router_ipaddr "ipfw queue 1 config sched 1"
    ssh -i ~/.ssh/mptcprootkey root@$router_ipaddr "ipfw add 100 queue 1 ip from any to any"
}