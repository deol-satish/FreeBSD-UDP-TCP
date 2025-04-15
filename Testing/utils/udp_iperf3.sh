#!/bin/bash

# tcp_udp_client_iperf3_script() {
#     sleep 5
#     iter=$1
#     aqm=$2
#     bw=$3
#     d=$4
#     e=$5
#     protocol=$6
#     echo "Iteration: $iter, AQM: $aqm, Bandwidth: $bw, Delay: $d, ECN: $e"
#     testname="${iter}_${aqm}_${bw}_${d}_${e}_${protocol}"
#     echo "testname: $testname"
#     echo "TCP Running iperf3 client-side test, iteration $iter"
#     # ssh -i ~/.ssh/mptcprootkey root@$client2_ipaddr "iperf3 -c 192.168.3.2 -t $duration -p 5103 -J > iperf3_client_${tcp2}_${testname}.json" &
#     ssh -i ~/.ssh/mptcprootkey root@$client2_ipaddr "iperf3 -c 192.168.3.2 -t $duration -p 5101 -J -C cubic > iperf3_client_cubic_${testname}.json" &
#     ssh -i ~/.ssh/mptcprootkey root@$client2_ipaddr "iperf3 -c 192.168.3.2 -t $duration -p 5102 -J > iperf3_client_${tcp1}_${testname}.json"
    
#     sleep $end_wait_time
# }

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

    # Start UDP receiver on server
    
    ssh -i ~/.ssh/mptcprootkey root@$server_ipaddr "./udp_prague/udp_prague_receiver -p 8082 > udp_prague_receiver_${testname}.txt" &
    
    sleep 2
    ssh -i ~/.ssh/mptcprootkey root@$client1_ipaddr "./udp_prague/udp_prague_sender -a 192.168.3.2 -p 8082 -c > udp_prague_sender_${testname}.txt" &
    ssh -i ~/.ssh/mptcprootkey root@$client2_ipaddr "iperf3 -c 192.168.3.2 -t $duration -p 5101 -J -C cubic > iperf3_client_cubic_${testname}.json" &
    ssh -i ~/.ssh/mptcprootkey root@$client2_ipaddr "iperf3 -c 192.168.3.2 -t $duration -p 5102 -J > iperf3_client_${tcp1}_${testname}.json" 
    

    ssh -i ~/.ssh/mptcprootkey root@$server_ipaddr "cd udp_prague; pkill -f udp_prague_receiver"
    
    sleep $end_wait_time
}

cused_udp_client_iperf3_script() {
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

    # Start UDP receiver on server
    
    ssh -i ~/.ssh/mptcprootkey root@$server_ipaddr "./udp_prague/udp_prague_receiver -p 8082 > udp_prague_receiver_${testname}.txt" &
    
    sleep 2
    ssh -i ~/.ssh/mptcprootkey root@$client1_ipaddr "./udp_prague/udp_prague_sender -a 192.168.3.2 -p 8082 -c > udp_prague_sender_${testname}.txt" &
    # ssh -i ~/.ssh/mptcprootkey root@$client2_ipaddr "iperf3 -c 192.168.3.2 -t $duration -p 5101 -J -C cubic > iperf3_client_cubic_${testname}.json" &
    ssh -i ~/.ssh/mptcprootkey root@$client2_ipaddr "iperf3 -c 192.168.3.2 -t $duration -p 5102 -J > iperf3_client_${tcp1}_${testname}.json" 
    

    ssh -i ~/.ssh/mptcprootkey root@$server_ipaddr "cd udp_prague; pkill -f udp_prague_receiver"
    
    sleep $end_wait_time
}