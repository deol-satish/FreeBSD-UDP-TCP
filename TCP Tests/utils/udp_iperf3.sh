#!/bin/bash


udp_client_iperf3_script() {
    sleep 5
    iter=$1
    aqm=$2
    bw=$3
    d=$4
    e=$5
    protocol=$6
    echo "Iteration: $iter, AQM: $aqm, Bandwidth: $bw, Delay: $d, ECN: $e"
    testname="${iter}_${aqm}_${bw}_${d}_${e}_${protocol}"
    echo "testname: $testname"
    echo "Running UDP iperf3 client-side test, iteration $iter"
    
    ssh -p "$src1port" -i "$sshkeypath" root@"$vmhostaddr" "iperf3 -u -c 172.16.1.2 -t $duration -p 5101 -J > iperf3_client_udp_src1_${testname}.json" &
    ssh -p "$src2port" -i "$sshkeypath" root@"$vmhostaddr" "iperf3 -u -c 172.16.1.2 -t $duration -p 5102 -J > iperf3_client_udp_src2_${testname}.json" &

    sleep $end_wait_time
}