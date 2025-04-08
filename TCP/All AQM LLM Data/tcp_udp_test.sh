#!/bin/bash

# Set basic configuration values
set -x

# TCP variants
tcp1="newreno"
tcp2="dctcp"

# AQM schemes
aqm_schemes=("l4s")
aqm_schemes=("l4s" "fq_pie" "fq_codel")

# Bandwidth, delay, and ECN settings
bandwidth=("10Mbps" "5Mbps" "8Mbps" "20Mbps")
delay=("0ms" "1ms" "5ms" "7ms" "10ms" "20ms")

# bandwidth=("5Mbps")
# delay=("0ms")

ecn=("ecn")

# Set TCP ECN enable on clients
tcp_ecn_enable=1
dctcp_ect1=1

# Set test duration (60 seconds) and wait time
duration=60
end_wait_time=10

# Access to VMs and router
src1host="test2"
src1port="3323"
src2host="server"
src2port="4423"
dsthost="client1"
dsthostport="3322"
router1host="dummynetVM1"
router1port="4422"

# Enable or disable SIFTR and TCPDUMP
do_siftr="1"
do_tcpdump="1"

# SSH key settings
sshkey="mptcprootkey"
sshkeypath="$HOME/.ssh/mptcprootkey"
vmhostaddr="192.168.56.1"

# Number of iterations to run (10 times)
iterations=2

# Function to configure TCP CC and ECN on Source
configure_tcp_cc_ecn() {
    ecn_status=$1
    echo "Configuring TCP CC and ECN on sources"
    ssh -i ~/.ssh/mptcprootkey root@$client1_ipaddr "kldload cc_$tcp1"
    ssh -i ~/.ssh/mptcprootkey root@$client1_ipaddr "sysctl net.inet.tcp.cc.algorithm=$tcp1"
    ssh -i ~/.ssh/mptcprootkey root@$client2_ipaddr "kldload cc_$tcp2"
    ssh -i ~/.ssh/mptcprootkey root@$client2_ipaddr "sysctl net.inet.tcp.cc.algorithm=$tcp2"

    # Set DCTCP ECT1
    if [ "$tcp1" == "dctcp" ]; then
        ssh -i ~/.ssh/mptcprootkey root@$client1_ipaddr "sysctl net.inet.tcp.cc.dctcp.ect1=$dctcp_ect1"
    fi

    if [ "$tcp2" == "dctcp" ]; then
        ssh -i ~/.ssh/mptcprootkey root@$client2_ipaddr "sysctl net.inet.tcp.cc.dctcp.ect1=$dctcp_ect1"
    fi

    # Set ECN enable
    if [ "$ecn_status" == "ecn" ]; then
        ssh -i ~/.ssh/mptcprootkey root@$client1_ipaddr "sysctl net.inet.tcp.ecn.enable=$tcp_ecn_enable"
        ssh -i ~/.ssh/mptcprootkey root@$client2_ipaddr "sysctl net.inet.tcp.ecn.enable=$tcp_ecn_enable"
        ssh -i ~/.ssh/mptcprootkey root@$router_ipaddr "sysctl net.inet.tcp.ecn.enable=$tcp_ecn_enable"
    elif [ "$ecn_status" == "noecn" ]; then
        ssh -i ~/.ssh/mptcprootkey root@$client1_ipaddr "sysctl net.inet.tcp.ecn.enable=0"
        ssh -i ~/.ssh/mptcprootkey root@$client2_ipaddr "sysctl net.inet.tcp.ecn.enable=0"
        ssh -i ~/.ssh/mptcprootkey root@$router_ipaddr "sysctl net.inet.tcp.ecn.enable=0"
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

# Function to run iperf3 client and server
tcp_client_iperf3_script() {
    sleep 5
    iter=$1
    aqm=$2
    bw=$3
    d=$4
    e=$5
    echo "Starting logging data"
    echo "Iteration: $iter, AQM: $aqm, Bandwidth: $bw, Delay: $d, ECN: $e"
    testname="${iter}_${aqm}_${bw}_${d}_${e}"
    echo "testname: $testname"
    echo "Running iperf3 client-side test, iteration $iter"
    ssh -i ~/.ssh/mptcprootkey root@$client2_ipaddr "iperf3 -c 172.16.1.2 -t $duration -p 5103 -J > iperf3_client_${tcp2}_${testname}.json" &
    ssh -i ~/.ssh/mptcprootkey root@$client1_ipaddr "iperf3 -c 172.16.1.2 -t $duration -p 5101 -J -C cubic > iperf3_client_cubic_${testname}.json" &
    ssh -i ~/.ssh/mptcprootkey root@$client1_ipaddr "iperf3 -c 172.16.1.2 -t $duration -p 5102 -J > iperf3_client_${tcp1}_${testname}.json"
    
    sleep $end_wait_time
}

# Function to run iperf3 client and server
udp_client_iperf3_script() {
    sleep 5
    iter=$1
    aqm=$2
    bw=$3
    d=$4
    e=$5
    echo "Starting logging data"
    echo "Iteration: $iter, AQM: $aqm, Bandwidth: $bw, Delay: $d, ECN: $e"
    testname="${iter}_${aqm}_${bw}_${d}_${e}"
    echo "testname: $testname"
    echo "Running iperf3 client-side test, iteration $iter"
    ssh -i ~/.ssh/mptcprootkey root@$client2_ipaddr "iperf3 -c  172.16.1.2 -u -t $duration -p 5103 -J > iperf3_client_src2_${testname}.json" &
    ssh -i ~/.ssh/mptcprootkey root@$client1_ipaddr "iperf3 -c  172.16.1.2 -u -t $duration -p 5101 -J > iperf3_client_src1_${testname}.json" &
    ssh -i ~/.ssh/mptcprootkey root@$client1_ipaddr "iperf3 -c  172.16.1.2 -u -t $duration -p 5102 -J > iperf3_client_src1_${testname}.json"
    
    sleep $end_wait_time
}

server_iperf3_script() {
    # iter=$1
    # testname="${iter}_${aqm}_${bw}_${d}_${e}"
    echo "Running iperf3 server-side test"
    ssh -i ~/.ssh/mptcprootkey root@$server_ipaddr "screen -dmS session1 iperf3 -s -p 5101 --rcv-timeout 18000000" &
    ssh -i ~/.ssh/mptcprootkey root@$server_ipaddr "screen -dmS session2 iperf3 -s -p 5102 --rcv-timeout 18000000" &
    ssh -i ~/.ssh/mptcprootkey root@$server_ipaddr "screen -dmS session3 iperf3 -s -p 5103 --rcv-timeout 18000000" &
}


kill_server_iperf3_script() {
    echo "Running iperf3 server-side test"
    ssh -i ~/.ssh/mptcprootkey root@$server_ipaddr "pkill screen"
    ssh -i ~/.ssh/mptcprootkey root@$server_ipaddr "killall screen"
}


# Function to start logging data
start_log(){
    iter=$1
    aqm=$2
    bw=$3
    d=$4
    e=$5
    echo "Starting logging data"
    echo "Iteration: $iter, AQM: $aqm, Bandwidth: $bw, Delay: $d, ECN: $e"
    testname="${iter}_${aqm}_${bw}_${d}_${e}"
    echo "testname: $testname"
    # Configure siftr, if enabled
    if [ "$do_siftr" -eq 1 ]; then
        sleep 1
        echo "Starting siftr on $src1host"
        ssh -i ~/.ssh/mptcprootkey root@$client1_ipaddr \
        "rm /root/${testname}_${tcp1}_src1.siftr.log && touch /root/${testname}_${tcp1}_src1.siftr.log ;sysctl net.inet.siftr.logfile=/root/${testname}_${tcp1}_src1.siftr.log"
        ssh -i ~/.ssh/mptcprootkey root@$client1_ipaddr \
        "sysctl net.inet.siftr.enabled=1"

        echo "Starting siftr on $src2host"
        ssh -i ~/.ssh/mptcprootkey root@$client2_ipaddr \
        "rm /root/${testname}_${tcp2}_src2.siftr.log && touch /root/${testname}_${tcp2}_src2.siftr.log ;sysctl net.inet.siftr.logfile=/root/${testname}_${tcp2}_src2.siftr.log"
        ssh -i ~/.ssh/mptcprootkey root@$client2_ipaddr \
        "sysctl net.inet.siftr.enabled=1"

        sleep 1
        echo "Starting siftr on $dsthost"
        ssh -i ~/.ssh/mptcprootkey root@$server_ipaddr \
        "rm /root/${testname}_dsthost.siftr.log && touch /root/${testname}_dsthost.siftr.log ; sysctl net.inet.siftr.logfile=/root/${testname}_dsthost.siftr.log"
        ssh -i ~/.ssh/mptcprootkey root@$server_ipaddr \
        "sysctl net.inet.siftr.enabled=1"
    fi

    if [ "$do_tcpdump" -eq 1 ]; then
        sleep 1
        echo "Starting tcpdump on $src1host"
        ssh -i ~/.ssh/mptcprootkey root@$client1_ipaddr "tcpdump -i em1 -w /root/${testname}_${tcp1}_src1.em1.pcap > tcpdump.em1.out 2>&1 & tcpdump -i em2 -w /root/${testname}_${tcp1}_src1.em2.pcap > tcpdump.em2.out 2>&1 &"

        sleep 1
        echo "Starting tcpdump on $src2host"
        ssh -i ~/.ssh/mptcprootkey root@$client2_ipaddr "tcpdump -i em1 -w /root/${testname}_${tcp2}_src2.em1.pcap > tcpdump.em1.out 2>&1 & tcpdump -i em2 -w /root/${testname}_${tcp2}_src2.em2.pcap > tcpdump.em2.out 2>&1 & tcpdump -i em3 -w /root/${testname}_${tcp2}_src2.em3.pcap > tcpdump.em3.out 2>&1 &"

        sleep 1
        echo "Starting tcpdump on $dsthost"
        ssh -i ~/.ssh/mptcprootkey root@$server_ipaddr "tcpdump -i em1 -w /root/${testname}_dsthost.em1.pcap > tcpdump.em1.out 2>&1 & tcpdump -i em2 -w /root/${testname}_dsthost.em2.pcap > tcpdump.em2.out 2>&1 &"
    fi


    
}

# Function to end logging data
end_log(){
    # Stop siftr, if enabled
    if [ "$do_siftr" -eq 1 ]; then
        sleep 1
        echo "Stop siftr on $src1host"
        ssh -i ~/.ssh/mptcprootkey root@$client1_ipaddr \
        "sysctl net.inet.siftr.enabled=0"

        sleep 1
        echo "Stop siftr on $src2host"
        ssh -i ~/.ssh/mptcprootkey root@$client2_ipaddr \
        "sysctl net.inet.siftr.enabled=0"

        sleep 1
        echo "Stop siftr on $dsthost"
        ssh -i ~/.ssh/mptcprootkey root@$server_ipaddr \
        "sysctl net.inet.siftr.enabled=0"
    fi

    # Stop tcpdump, if enabled
    if [ "$do_tcpdump" -eq 1 ]; then
        sleep 1
        echo "Stop tcpdump on $src1host"
        ssh -i ~/.ssh/mptcprootkey root@$client1_ipaddr \
        "killall tcpdump"
    fi

    # Stop tcpdump, if enabled
    if [ "$do_tcpdump" -eq 1 ]; then
        sleep 1
        echo "Stop tcpdump on $src2host"
        ssh -i ~/.ssh/mptcprootkey root@$client2_ipaddr \
        "killall tcpdump"
    fi

    # Stop tcpdump on dsthost, if enabled
    if [ "$do_tcpdump" -eq 1 ]; then
        sleep 1
        echo "Stop tcpdump on $dsthost"
        ssh -i ~/.ssh/mptcprootkey root@$server_ipaddr \
        "killall tcpdump"
    fi
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
    echo "Starting logging data"
    echo "Iteration: $iter, AQM: $aqm, Bandwidth: $bw, Delay: $d, ECN: $e"
    testname="${iter}_${aqm}_${bw}_${d}_${e}"
    echo "testname: $testname"
    mkdir -p ./server_data
    mkdir -p ./client1_data
    mkdir -p ./client2_data
    mkdir -p ./router_data
    mkdir -p ./Graphs
    mkdir -p ./stats

    ssh -i ~/.ssh/mptcprootkey root@$router_ipaddr "cat /var/log/messages > kernel_data_${testname}.txt"
}



data_download()
{
    echo "Starting downloading data"

    mkdir -p ./server_data
    mkdir -p ./client1_data
    mkdir -p ./client2_data
    mkdir -p ./router_data
    mkdir -p ./Graphs
    mkdir -p ./stats

    scp -p -i "$sshkeypath" root@"$server_ipaddr":*.siftr.log ./server_data; 
    scp -p -i "$sshkeypath" root@"$server_ipaddr":*.pcap ./server_data;
    scp -p -i "$sshkeypath" root@"$server_ipaddr":*.out ./server_data;
    scp -p -i "$sshkeypath" root@"$server_ipaddr":*.json ./server_data;

    scp -p -i "$sshkeypath" root@"$client1_ipaddr":*.siftr.log ./client1_data;
    scp -p -i "$sshkeypath" root@"$client1_ipaddr":*.json ./client1_data;
    scp -p -i "$sshkeypath" root@"$client1_ipaddr":*.pcap ./client1_data;
    scp -p -i "$sshkeypath" root@"$client1_ipaddr":*.out ./client1_data;
    scp -p -i "$sshkeypath" root@"$client2_ipaddr":*.siftr.log ./client2_data;
    scp -p -i "$sshkeypath" root@"$client2_ipaddr":*.json ./client2_data;
    scp -p -i "$sshkeypath" root@"$client2_ipaddr":*.pcap ./client2_data;
    scp -p -i "$sshkeypath" root@"$client2_ipaddr":*.out ./client2_data;

    # ssh -i ~/.ssh/mptcprootkey root@$router_ipaddr "cat /var/log/messages > kernel_data_{$testname}.txt"

    scp -p -i "$sshkeypath" root@"$router_ipaddr":*txt ./router_data; 
}

# Cleanup previous data and iperf3 instances
cleanup() {
    echo "Cleaning up previous data and processes"
    ssh -i ~/.ssh/mptcprootkey root@$client1_ipaddr "rm *.siftr.log;rm *.pcap;rm *.out; killall iperf3"
    ssh -i ~/.ssh/mptcprootkey root@$client2_ipaddr "rm *.siftr.log;rm *.pcap;rm *.out; killall iperf3"
    ssh -i ~/.ssh/mptcprootkey root@$server_ipaddr "rm *.siftr.log;rm *.pcap;rm *.out"
}

# Before starting delete all previous files
ssh -i ~/.ssh/mptcprootkey root@$client1_ipaddr "rm *.siftr.log;rm *.pcap;rm *.out"
ssh -i ~/.ssh/mptcprootkey root@$client2_ipaddr "rm *.siftr.log;rm *.pcap;rm *.out"
ssh -i ~/.ssh/mptcprootkey root@$server_ipaddr "rm *.siftr.log;rm *.pcap;rm *.out"
ssh -i ~/.ssh/mptcprootkey root@$router_ipaddr "rm *.txt"

ssh -i ~/.ssh/mptcprootkey root@$client1_ipaddr "killall iperf3"
ssh -i ~/.ssh/mptcprootkey root@$client2_ipaddr "killall iperf3"
#ssh -i ~/.ssh/mptcprootkey root@$server_ipaddr "killall iperf3"

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
                    ssh -i ~/.ssh/mptcprootkey root@$router_ipaddr "truncate -s 0 /var/log/messages"
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
