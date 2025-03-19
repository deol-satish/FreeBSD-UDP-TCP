#!/bin/bash

# Set basic configuration values
source ../utils/settings.sh

# Function to end logging data
end_log(){
    # Stop siftr, if enabled
    if [ "$do_siftr" -eq 1 ]; then
        
        echo "Stop siftr on $src1host"
        ssh -p "$src1port" -i "$sshkeypath" root@"$vmhostaddr" \
        "sysctl net.inet.siftr.enabled=0"

        
        echo "Stop siftr on $src2host"
        ssh -p "$src2port" -i "$sshkeypath" root@"$vmhostaddr" \
        "sysctl net.inet.siftr.enabled=0"

        
        echo "Stop siftr on $dsthost"
        ssh -p "$dsthostport" -i "$sshkeypath" root@"$vmhostaddr" \
        "sysctl net.inet.siftr.enabled=0"
    fi

    # Stop tcpdump, if enabled
    if [ "$do_tcpdump" -eq 1 ]; then
        
        echo "Stop tcpdump on $src1host"
        ssh -p "$src1port" -i "$sshkeypath" root@"$vmhostaddr" \
        "killall tcpdump"
    fi

    # Stop tcpdump, if enabled
    if [ "$do_tcpdump" -eq 1 ]; then
        
        echo "Stop tcpdump on $src2host"
        ssh -p "$src2port" -i "$sshkeypath" root@"$vmhostaddr" \
        "killall tcpdump"
    fi

    # Stop tcpdump on dsthost, if enabled
    if [ "$do_tcpdump" -eq 1 ]; then
        
        echo "Stop tcpdump on $dsthost"
        ssh -p "$dsthostport" -i "$sshkeypath" root@"$vmhostaddr" \
        "killall tcpdump"
    fi
    
}

ssh -p "$src1port" -i "$sshkeypath" root@"$vmhostaddr" "rm *.siftr.log;rm *.pcap;rm *.out;rm *.json"
ssh -p "$src2port" -i "$sshkeypath" root@"$vmhostaddr" "rm *.siftr.log;rm *.pcap;rm *.out;rm *.json"
ssh -p "$dsthostport" -i "$sshkeypath" root@"$vmhostaddr" "rm *.siftr.log;rm *.pcap;rm *.out;rm *.json"
ssh -p "$router1port" -i "$sshkeypath" root@"$vmhostaddr" "rm *.siftr.log;rm *.pcap;rm *.out;rm *.json"

ssh -p "$router1port" -i "$sshkeypath" root@"$vmhostaddr" "truncate -s 0 /var/log/messages"

ssh -p "$router1port" -i "$sshkeypath" root@"$vmhostaddr" "rm *.txt"

ssh -p "$src1port" -i "$sshkeypath" root@"$vmhostaddr" "killall iperf3"
ssh -p "$src2port" -i "$sshkeypath" root@"$vmhostaddr" "killall iperf3"
ssh -p "$dsthostport" -i "$sshkeypath" root@"$vmhostaddr" "killall iperf3"

ssh -p "$dsthostport" -i "$sshkeypath" root@"$vmhostaddr" "pkill screen"
ssh -p "$dsthostport" -i "$sshkeypath" root@"$vmhostaddr" "killall screen"

end_log
# completed
echo "Reset complete"
exit 0

# error
out() {
    echo "Abort test"
    exit 1
}