#!/bin/bash

data_download()
{
    echo "Starting downloading data"

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
    scp -P "$src1port" -p -i "$sshkeypath" root@"$vmhostaddr":*.out ./client1_data;
    scp -P "$src2port" -p -i "$sshkeypath" root@"$vmhostaddr":*.siftr.log ./client2_data;
    scp -P "$src2port" -p -i "$sshkeypath" root@"$vmhostaddr":*.json ./client2_data;
    scp -P "$src2port" -p -i "$sshkeypath" root@"$vmhostaddr":*.pcap ./client2_data;
    scp -P "$src2port" -p -i "$sshkeypath" root@"$vmhostaddr":*.out ./client2_data;

    # ssh -p "$router1port" -i "$sshkeypath" root@"$vmhostaddr" "cat /var/log/messages > kernel_data_{$testname}.txt"

    scp -P "$router1port" -p -i "$sshkeypath" root@"$vmhostaddr":*txt ./router_data; 
}

# Cleanup previous data and iperf3 instances
cleanup() {
    echo "Cleaning up previous data and processes"
    ssh -p "$src1port" -i "$sshkeypath" root@"$vmhostaddr" "rm *.siftr.log;rm *.pcap;rm *.out; killall iperf3"
    ssh -p "$src2port" -i "$sshkeypath" root@"$vmhostaddr" "rm *.siftr.log;rm *.pcap;rm *.out; killall iperf3"
    ssh -p "$dsthostport" -i "$sshkeypath" root@"$vmhostaddr" "rm *.siftr.log;rm *.pcap;rm *.out"
}


kernel_data_create()
{
    iter=$1
    aqm=$2
    bw=$3
    d=$4
    e=$5
    echo "Kernel data collection Start"
    echo "Iteration: $iter, AQM: $aqm, Bandwidth: $bw, Delay: $d, ECN: $e"
    testname="${iter}_${aqm}_${bw}_${d}_${e}"
    echo "testname: $testname"

    ssh -p "$router1port" -i "$sshkeypath" root@"$vmhostaddr" "cat /var/log/messages > kernel_data_${testname}.txt"
}
