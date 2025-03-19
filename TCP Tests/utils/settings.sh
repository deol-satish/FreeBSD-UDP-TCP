#!/bin/bash

# TCP variants
tcp1="newreno"
tcp2="dctcp"

# AQM schemes
aqm_schemes=("l4s")
# aqm_schemes=("l4s" "fq_pie" "fq_codel")

# Bandwidth, delay, and ECN settings




bandwidth=("10Mbps" "5Mbps" "8Mbps" "20Mbps")
delay=("0ms" "10ms" "20ms" "30ms" "40ms")

# bandwidth=("10Mbps" "5Mbps")
# delay=("0ms")

ecn=("ecn")

# Set TCP ECN enable on clients
tcp_ecn_enable=1
dctcp_ect1=1

# Set test duration (60 seconds) and wait time
duration=120
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
iterations=3
