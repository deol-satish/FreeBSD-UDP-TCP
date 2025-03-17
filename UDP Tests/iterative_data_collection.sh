#!/bin/bash

# Set basic configuration values
set -x

source ./utils/settings.sh
source ./utils/router_config.sh
source ./utils/tcp_iperf3.sh
source ./utils/logger.sh
source ./utils/util.sh


# Before starting delete all previous files
ssh -p "$src1port" -i "$sshkeypath" root@"$vmhostaddr" "rm *.siftr.log;rm *.pcap;rm *.out"
ssh -p "$src2port" -i "$sshkeypath" root@"$vmhostaddr" "rm *.siftr.log;rm *.pcap;rm *.out"
ssh -p "$dsthostport" -i "$sshkeypath" root@"$vmhostaddr" "rm *.siftr.log;rm *.pcap;rm *.out"
ssh -p "$router1port" -i "$sshkeypath" root@"$vmhostaddr" "rm *.txt"

ssh -p "$src1port" -i "$sshkeypath" root@"$vmhostaddr" "killall iperf3"
ssh -p "$src2port" -i "$sshkeypath" root@"$vmhostaddr" "killall iperf3"
#ssh -p "$dsthostport" -i "$sshkeypath" root@"$vmhostaddr" "killall iperf3"

rm -r ./server_data
rm -r ./client1_data
rm -r ./client2_data
rm -r ./Graphs
rm -r ./stats

server_iperf3_script
# Function to run the test
run_test() {
    iter=$1
    for aqm in "${aqm_schemes[@]}"; do
        for bw in "${bandwidth[@]}"; do
            for d in "${delay[@]}"; do
                for e in "${ecn[@]}"; do
                    server_iperf3_script
                    configure_tcp_cc_ecn "$e"
                    configure_routers "$aqm" "$bw" "$d" "$e"
                    start_log "$iter" "$aqm" "$bw" "$d" "$e"
                    # server_iperf3_script "$iter"
                    client_iperf3_script "$iter" "$aqm" "$bw" "$d" "$e"
                    end_log
                    kill_server_iperf3_script
                    kernel_data_create "$iter" "$aqm" "$bw" "$d" "$e"
                    sleep 1
                    ssh -p "$router1port" -i "$sshkeypath" root@"$vmhostaddr" "truncate -s 0 /var/log/messages"
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
