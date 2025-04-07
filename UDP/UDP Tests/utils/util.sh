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
    scp -P "$dsthostport" -p -i "$sshkeypath" root@"$vmhostaddr":*.siftr.log "$base_dir/server_data"
    scp -P "$dsthostport" -p -i "$sshkeypath" root@"$vmhostaddr":*.pcap "$base_dir/server_data"
    scp -P "$dsthostport" -p -i "$sshkeypath" root@"$vmhostaddr":*.out "$base_dir/server_data"
    scp -P "$dsthostport" -p -i "$sshkeypath" root@"$vmhostaddr":*.json "$base_dir/server_data"

    scp -P "$src1port" -p -i "$sshkeypath" root@"$vmhostaddr":*.siftr.log "$base_dir/client1_data"
    scp -P "$src1port" -p -i "$sshkeypath" root@"$vmhostaddr":*.json "$base_dir/client1_data"
    scp -P "$src1port" -p -i "$sshkeypath" root@"$vmhostaddr":*.pcap "$base_dir/client1_data"
    scp -P "$src1port" -p -i "$sshkeypath" root@"$vmhostaddr":*.out "$base_dir/client1_data"

    scp -P "$src2port" -p -i "$sshkeypath" root@"$vmhostaddr":*.siftr.log "$base_dir/client2_data"
    scp -P "$src2port" -p -i "$sshkeypath" root@"$vmhostaddr":*.json "$base_dir/client2_data"
    scp -P "$src2port" -p -i "$sshkeypath" root@"$vmhostaddr":*.pcap "$base_dir/client2_data"
    scp -P "$src2port" -p -i "$sshkeypath" root@"$vmhostaddr":*.out "$base_dir/client2_data"

    # Uncomment the below line if you need to capture kernel logs
    # ssh -p "$router1port" -i "$sshkeypath" root@"$vmhostaddr" "cat /var/log/messages > kernel_data_${testname}.txt"

    scp -P "$router1port" -p -i "$sshkeypath" root@"$vmhostaddr":*txt "$base_dir/kernel_data"

    echo "Data download complete. Files are saved in $base_dir"
}


# Cleanup previous data and iperf3 instances
cleanup() {
    end_log
    echo "Cleaning up previous data and processes"
    ssh -p "$src1port" -i "$sshkeypath" root@"$vmhostaddr" "rm *.siftr.log;rm *.pcap;rm *.out; killall iperf3;rm *.json"
    ssh -p "$src2port" -i "$sshkeypath" root@"$vmhostaddr" "rm *.siftr.log;rm *.pcap;rm *.out; killall iperf3;rm *.json"
    ssh -p "$dsthostport" -i "$sshkeypath" root@"$vmhostaddr" "rm *.siftr.log;rm *.pcap;rm *.out; killall iperf3;rm *.json"
    ssh -p "$router1port" -i "$sshkeypath" root@"$vmhostaddr" "rm *.txt"

    ssh -p "$router1port" -i "$sshkeypath" root@"$vmhostaddr" "truncate -s 0 /var/log/messages"

    ssh -p "$router1port" -i "$sshkeypath" root@"$vmhostaddr" "rm *.txt"

    ssh -p "$dsthostport" -i "$sshkeypath" root@"$vmhostaddr" "pkill screen"
    ssh -p "$dsthostport" -i "$sshkeypath" root@"$vmhostaddr" "killall screen"
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

    ssh -p "$router1port" -i "$sshkeypath" root@"$vmhostaddr" "cat /var/log/messages > kernel_data_${testname}.txt"
}
