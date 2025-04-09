#!/bin/bash

set -x

# Set basic configuration values
source ../utils/settings.sh

# Function to end logging data
end_log(){
    # Stop siftr, if enabled
    if [ "$do_siftr" -eq 1 ]; then
        
        echo "Stop siftr on $src1host"
        ssh -i ~/.ssh/mptcprootkey root@$client1_ipaddr \
        "sysctl net.inet.siftr.enabled=0"

        
        echo "Stop siftr on $src2host"
        ssh -i ~/.ssh/mptcprootkey root@$client2_ipaddr \
        "sysctl net.inet.siftr.enabled=0"

        
        echo "Stop siftr on $dsthost"
        ssh -i ~/.ssh/mptcprootkey root@$server_ipaddr \
        "sysctl net.inet.siftr.enabled=0"
    fi

    # Stop tcpdump, if enabled
    if [ "$do_tcpdump" -eq 1 ]; then
        
        echo "Stop tcpdump on $src1host"
        ssh -i ~/.ssh/mptcprootkey root@$client1_ipaddr \
        "killall tcpdump"
    fi

    # Stop tcpdump, if enabled
    if [ "$do_tcpdump" -eq 1 ]; then
        
        echo "Stop tcpdump on $src2host"
        ssh -i ~/.ssh/mptcprootkey root@$client2_ipaddr \
        "killall tcpdump"
    fi

    # Stop tcpdump on dsthost, if enabled
    if [ "$do_tcpdump" -eq 1 ]; then
        
        echo "Stop tcpdump on $dsthost"
        ssh -i ~/.ssh/mptcprootkey root@$server_ipaddr \
        "killall tcpdump"
    fi
    
}

ssh -i ~/.ssh/mptcprootkey root@$client1_ipaddr "rm *.siftr.log;rm *.pcap;rm *.out;rm *.json;rm *dualpi2*.txt"
ssh -i ~/.ssh/mptcprootkey root@$client2_ipaddr "rm *.siftr.log;rm *.pcap;rm *.out;rm *.json;rm *dualpi2*.txt"
ssh -i ~/.ssh/mptcprootkey root@$server_ipaddr "rm *.siftr.log;rm *.pcap;rm *.out;rm *.json;rm *dualpi2*.txt"
ssh -i ~/.ssh/mptcprootkey root@$router_ipaddr "rm *.siftr.log;rm *.pcap;rm *.out;rm *.json;rm *dualpi2*.txt"

ssh -i ~/.ssh/mptcprootkey root@$router_ipaddr "truncate -s 0 /var/log/messages"

ssh -i ~/.ssh/mptcprootkey root@$router_ipaddr "rm *.txt"

ssh -i ~/.ssh/mptcprootkey root@$client1_ipaddr "killall iperf3;pkill -f udp_prague_sender"
ssh -i ~/.ssh/mptcprootkey root@$client2_ipaddr "killall iperf3;pkill -f udp_prague_sender"
ssh -i ~/.ssh/mptcprootkey root@$server_ipaddr "killall iperf3"

ssh -i ~/.ssh/mptcprootkey root@$server_ipaddr "pkill screen; pkill -f udp_prague_receiver"
ssh -i ~/.ssh/mptcprootkey root@$server_ipaddr "killall screen"


end_log
# completed
echo "Reset complete"
exit 0

# error
out() {
    echo "Abort test"
    exit 1
}