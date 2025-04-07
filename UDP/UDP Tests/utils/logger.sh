#!/bin/bash

# Function to start logging data
start_log(){
    iter=$1
    aqm=$2
    bw=$3
    d=$4
    e=$5
    protocol=$6
    echo "Starting logging data"
    echo "Iteration: $iter, AQM: $aqm, Bandwidth: $bw, Delay: $d, ECN: $e"
    testname="${iter}_${aqm}_${bw}_${d}_${e}_${protocol}"
    echo "testname: $testname"
    # Configure siftr, if enabled
    if [ "$do_siftr" -eq 1 ]; then
        
        echo "Starting siftr on $src1host"
        ssh -p "$src1port" -i "$sshkeypath" root@"$vmhostaddr" \
        "rm /root/${testname}_${tcp1}_src1.siftr.log && touch /root/${testname}_${tcp1}_src1.siftr.log ;sysctl net.inet.siftr.logfile=/root/${testname}_${tcp1}_src1.siftr.log"
        ssh -p "$src1port" -i "$sshkeypath" root@"$vmhostaddr" \
        "sysctl net.inet.siftr.enabled=1"

        echo "Starting siftr on $src2host"
        ssh -p "$src2port" -i "$sshkeypath" root@"$vmhostaddr" \
        "rm /root/${testname}_${tcp2}_src2.siftr.log && touch /root/${testname}_${tcp2}_src2.siftr.log ;sysctl net.inet.siftr.logfile=/root/${testname}_${tcp2}_src2.siftr.log"
        ssh -p "$src2port" -i "$sshkeypath" root@"$vmhostaddr" \
        "sysctl net.inet.siftr.enabled=1"

        
        echo "Starting siftr on $dsthost"
        ssh -p "$dsthostport" -i "$sshkeypath" root@"$vmhostaddr" \
        "rm /root/${testname}_dsthost.siftr.log && touch /root/${testname}_dsthost.siftr.log ; sysctl net.inet.siftr.logfile=/root/${testname}_dsthost.siftr.log"
        ssh -p "$dsthostport" -i "$sshkeypath" root@"$vmhostaddr" \
        "sysctl net.inet.siftr.enabled=1"
    fi

    if [ "$do_tcpdump" -eq 1 ]; then
        
        echo "Starting tcpdump on $src1host"
        ssh -p "$src1port" -i "$sshkeypath" root@"$vmhostaddr" "tcpdump -i em1 -w /root/${testname}_${tcp1}_src1.em1.pcap > tcpdump.em1.out 2>&1 & tcpdump -i em2 -w /root/${testname}_${tcp1}_src1.em2.pcap > tcpdump.em2.out 2>&1 &"

        
        echo "Starting tcpdump on $src2host"
        ssh -p "$src2port" -i "$sshkeypath" root@"$vmhostaddr" "tcpdump -i em1 -w /root/${testname}_${tcp2}_src2.em1.pcap > tcpdump.em1.out 2>&1 & tcpdump -i em2 -w /root/${testname}_${tcp2}_src2.em2.pcap > tcpdump.em2.out 2>&1 & tcpdump -i em3 -w /root/${testname}_${tcp2}_src2.em3.pcap > tcpdump.em3.out 2>&1 &"

        
        echo "Starting tcpdump on $dsthost"
        ssh -p "$dsthostport" -i "$sshkeypath" root@"$vmhostaddr" "tcpdump -i em1 -w /root/${testname}_dsthost.em1.pcap > tcpdump.em1.out 2>&1 & tcpdump -i em2 -w /root/${testname}_dsthost.em2.pcap > tcpdump.em2.out 2>&1 &"
    fi


    
}

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
    ssh -p "$dsthostport" -i "$sshkeypath" root@"$vmhostaddr" "pkill screen"
    ssh -p "$dsthostport" -i "$sshkeypath" root@"$vmhostaddr" "killall screen"
}
