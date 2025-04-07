#!/bin/bash

# Function to run iperf3 client and server
# client_iperf3_script() {
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
#     ssh -p "$src2port" -i "$sshkeypath" root@"$vmhostaddr" "iperf3 -c 172.16.1.2 -t $duration -p 5103 -J > iperf3_client_${tcp2}_${testname}.json" &
#     ssh -p "$src1port" -i "$sshkeypath" root@"$vmhostaddr" "iperf3 -c 172.16.1.2 -t $duration -p 5101 -J -C cubic > iperf3_client_cubic_${testname}.json" &
#     ssh -p "$src1port" -i "$sshkeypath" root@"$vmhostaddr" "iperf3 -c 172.16.1.2 -t $duration -p 5102 -J > iperf3_client_${tcp1}_${testname}.json"
    
#     sleep $end_wait_time
# }

client_iperf3_script() {
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
    echo "TCP Running iperf3 client-side test, iteration $iter"
    # ssh -p "$src2port" -i "$sshkeypath" root@"$vmhostaddr" "iperf3 -c 172.16.1.2 -t $duration -p 5102 -J > iperf3_client_${tcp2}_${testname}.json" &
    # ssh -p "$src1port" -i "$sshkeypath" root@"$vmhostaddr" "iperf3 -c 172.16.1.2 -t $duration -p 5101 -J -C cubic > iperf3_client_cubic_${testname}.json" &
    ssh -p "$src1port" -i "$sshkeypath" root@"$vmhostaddr" "iperf3 -c 172.16.1.2 -t $duration -p 5101 -J > iperf3_client_${tcp1}_${testname}.json"
    
    sleep $end_wait_time
}

server_iperf3_script() {
    echo "Running iperf3 server-side test"
    ssh -p "$dsthostport" -i "$sshkeypath" root@"$vmhostaddr" "screen -dmS session1 iperf3 -s -p 5101 --rcv-timeout 36000000" &
    ssh -p "$dsthostport" -i "$sshkeypath" root@"$vmhostaddr" "screen -dmS session2 iperf3 -s -p 5102 --rcv-timeout 36000000" &
    ssh -p "$dsthostport" -i "$sshkeypath" root@"$vmhostaddr" "screen -dmS session3 iperf3 -s -p 5103 --rcv-timeout 36000000" &
    # ssh -p "$dsthostport" -i "$sshkeypath" root@"$vmhostaddr" "screen -dmS session3 iperf3 -s -p 5104 --rcv-timeout 36000000" &
}


kill_server_iperf3_script() {
    echo "Running iperf3 server-side test"
    ssh -p "$dsthostport" -i "$sshkeypath" root@"$vmhostaddr" "pkill screen"
    ssh -p "$dsthostport" -i "$sshkeypath" root@"$vmhostaddr" "killall screen"
}
