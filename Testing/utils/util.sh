#!/bin/bash

data_download() {
    echo "Starting downloading data"

    # Generate timestamp
    timestamp=$(date +"%Y-%m-%d-%H-%M-%S")

    # Create main directory with timestamp
    base_dir="./data/data_${timestamp}"
    mkdir -p "$base_dir/server_data"
    mkdir -p "$base_dir/client1_data"
    mkdir -p "$base_dir/client2_data"
    mkdir -p "$base_dir/kernel_data"
    mkdir -p "$base_dir/Graphs"
    mkdir -p "$base_dir/stats"

    # Download data into respective directories
    scp -p -i "$sshkeypath" root@"$server_ipaddr":*.siftr.log "$base_dir/server_data"
    scp -p -i "$sshkeypath" root@"$server_ipaddr":*.pcap "$base_dir/server_data"
    scp -p -i "$sshkeypath" root@"$server_ipaddr":*.out "$base_dir/server_data"
    scp -p -i "$sshkeypath" root@"$server_ipaddr":*.json "$base_dir/server_data"

    scp -p -i "$sshkeypath" root@"$client1_ipaddr":*.siftr.log "$base_dir/client1_data"
    scp -p -i "$sshkeypath" root@"$client1_ipaddr":*.json "$base_dir/client1_data"
    scp -p -i "$sshkeypath" root@"$client1_ipaddr":*.pcap "$base_dir/client1_data"
    scp -p -i "$sshkeypath" root@"$client1_ipaddr":*.out "$base_dir/client1_data"

    scp -p -i "$sshkeypath" root@"$client2_ipaddr":*.siftr.log "$base_dir/client2_data"
    scp -p -i "$sshkeypath" root@"$client2_ipaddr":*.json "$base_dir/client2_data"
    scp -p -i "$sshkeypath" root@"$client2_ipaddr":*.pcap "$base_dir/client2_data"
    scp -p -i "$sshkeypath" root@"$client2_ipaddr":*.out "$base_dir/client2_data"

    # Uncomment the below line if you need to capture kernel logs
    # ssh -i ~/.ssh/mptcprootkey root@$router_ipaddr "cat /var/log/messages > kernel_data_${testname}.txt"

    scp -p -i "$sshkeypath" root@"$router_ipaddr":*txt "$base_dir/kernel_data"

    echo "Data download complete. Files are saved in $base_dir"
}


# Cleanup previous data and iperf3 instances
cleanup() {
    end_log
    echo "Cleaning up previous data and processes"
    ssh -i ~/.ssh/mptcprootkey root@$client1_ipaddr "rm *.siftr.log;rm *.pcap;rm *.out; killall iperf3;rm *.json; pkill -f udp_prague_sender;rm *dualpi2*.txt"
    ssh -i ~/.ssh/mptcprootkey root@$client2_ipaddr "rm *.siftr.log;rm *.pcap;rm *.out; killall iperf3;rm *.json; pkill -f udp_prague_sender;rm *dualpi2*.txt"
    ssh -i ~/.ssh/mptcprootkey root@$server_ipaddr "rm *.siftr.log;rm *.pcap;rm *.out; killall iperf3;rm *.json; pkill -f udp_prague_receiver;rm *dualpi2*.txt"
    ssh -i ~/.ssh/mptcprootkey root@$router_ipaddr "rm *.txt"

    ssh -i ~/.ssh/mptcprootkey root@$router_ipaddr "truncate -s 0 /var/log/messages"

    ssh -i ~/.ssh/mptcprootkey root@$router_ipaddr "rm *.txt"

    ssh -i ~/.ssh/mptcprootkey root@$server_ipaddr "pkill screen"
    ssh -i ~/.ssh/mptcprootkey root@$server_ipaddr "killall screen"
}


kernel_data_create()
{
    iter=$1
    aqm=$2
    bw=$3
    d=$4
    e=$5
    protocol=$6
    echo "Kernel data collection Start"
    echo "Iteration: $iter, AQM: $aqm, Bandwidth: $bw, Delay: $d, ECN: $e"
    testname="${iter}_${aqm}_${bw}_${d}_${e}_${protocol}"
    echo "testname: $testname"

    ssh -i ~/.ssh/mptcprootkey root@$router_ipaddr "cat /var/log/messages > kernel_data_${testname}.txt"
}
