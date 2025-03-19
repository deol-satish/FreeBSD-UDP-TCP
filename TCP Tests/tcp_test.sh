#!/bin/bash

# Set basic configuration values
set -x

source ./utils/settings.sh
source ./utils/router_config.sh
source ./utils/tcp_iperf3.sh
source ./utils/logger.sh
source ./utils/util.sh
source ./utils/udp_iperf3.sh

cleanup

server_iperf3_script
# Function to run the test

run_tcp_test() {
    iter=$1
    aqm=$2
    bw=$3
    d=$4
    e=$5
    protocol="tcp"
    start_log "$iter" "$aqm" "$bw" "$d" "$e" "$protocol"
    # server_iperf3_script "$iter"
    client_iperf3_script "$iter" "$aqm" "$bw" "$d" "$e" "$protocol"
    end_log
    kill_server_iperf3_script
    kernel_data_create "$iter" "$aqm" "$bw" "$d" "$e" "$protocol"
    ssh -p "$router1port" -i "$sshkeypath" root@"$vmhostaddr" "truncate -s 0 /var/log/messages"
                    
}

run_udp_test() {
    iter=$1
    aqm=$2
    bw=$3
    d=$4
    e=$5
    protocol="udp"
    start_log "$iter" "$aqm" "$bw" "$d" "$e" "$protocol"
    # server_iperf3_script "$iter"
    udp_client_iperf3_script "$iter" "$aqm" "$bw" "$d" "$e" "$protocol"
    end_log
    kill_server_iperf3_script
    kernel_data_create "$iter" "$aqm" "$bw" "$d" "$e" "$protocol"
    ssh -p "$router1port" -i "$sshkeypath" root@"$vmhostaddr" "truncate -s 0 /var/log/messages"
                    
}


run_test() {
    iter=$1
    for aqm in "${aqm_schemes[@]}"; do
        for bw in "${bandwidth[@]}"; do
            for d in "${delay[@]}"; do
                for e in "${ecn[@]}"; do

                    # server_iperf3_script
                    configure_tcp_cc_ecn "$e"
                    configure_routers "$aqm" "$bw" "$d" "$e"
                    
                    #TCP Test Start
                    run_tcp_test "$iter" "$aqm" "$bw" "$d" "$e"

                    #UDP Test Start
                    run_udp_test "$iter" "$aqm" "$bw" "$d" "$e"                    
                    

                done
            done
        done
    done
}

# Main execution loop for running 10 iterations
for i in $(seq 1 $iterations); do
    echo "Running test iteration $i"
    run_test "$i"
    echo "Iteration $i completed"
done

data_download

# completed
echo "Test complete"
exit 0

# error
out() {
    echo "Abort test"
    exit 1
}
