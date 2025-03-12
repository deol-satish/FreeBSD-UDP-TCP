package main

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"time"

	"golang.org/x/crypto/ssh"
)

// Configuration variables
var (
	tcp1         = "newreno"
	tcp2         = "dctcp"
	aqmSchemes   = []string{"l4s", "fq_pie", "fq_codel"}
	bandwidths   = []string{"10Mbps", "5Mbps", "8Mbps", "20Mbps"}
	delays       = []string{"0ms", "1ms", "5ms", "7ms", "10ms", "20ms"}
	ecn          = []string{"ecn"}
	tcpEcnEnable = 1
	dctcpEct1    = 1
	duration     = 60
	endWaitTime  = 10
	iterations   = 2
	sshKeyPath   = "../setup/keys/mptcprootkey"
	vmHostAddr   = "192.168.56.1"
	src1Port     = 3323
	src2Port     = 4423
	dstPort      = 3322
	routerPort   = 4422
)

func main() {
	// Cleanup previous data and processes
	cleanup()

	// Run the test for the specified number of iterations
	for i := 1; i <= iterations; i++ {
		fmt.Printf("Running test iteration %d\n", i)
		runTest(i)
		fmt.Printf("Iteration %d completed\n", i)
	}

	// Download data after all iterations are complete
	dataDownload()

	fmt.Println("Test complete")
}

// Run the test for a single iteration
func runTest(iter int) {
	for _, aqm := range aqmSchemes {
		for _, bw := range bandwidths {
			for _, d := range delays {
				for _, e := range ecn {
					// Configure TCP CC and ECN
					configureTCPCCECN(e)

					// Configure routers
					configureRouters(aqm, bw, d, e)

					// Start logging
					startLog(iter, aqm, bw, d, e)

					// Run iperf3 client script
					clientIperf3Script(iter, aqm, bw, d, e)

					// End logging
					endLog()

					// Create kernel data
					kernelDataCreate(iter, aqm, bw, d, e)

					// Truncate logs
					truncateLogs()

					// Wait before the next iteration
					time.Sleep(1 * time.Second)
				}
			}
		}
	}
}

// Configure TCP congestion control and ECN
func configureTCPCCECN(ecnStatus string) {
	// Configure TCP CC for src1
	runSSHCommand(vmHostAddr, src1Port, fmt.Sprintf("kldload cc_%s", tcp1))
	runSSHCommand(vmHostAddr, src1Port, fmt.Sprintf("sysctl net.inet.tcp.cc.algorithm=%s", tcp1))

	// Configure TCP CC for src2
	runSSHCommand(vmHostAddr, src2Port, fmt.Sprintf("kldload cc_%s", tcp2))
	runSSHCommand(vmHostAddr, src2Port, fmt.Sprintf("sysctl net.inet.tcp.cc.algorithm=%s", tcp2))

	// Configure DCTCP ECT1 if applicable
	if tcp1 == "dctcp" {
		runSSHCommand(vmHostAddr, src1Port, fmt.Sprintf("sysctl net.inet.tcp.cc.dctcp.ect1=%d", dctcpEct1))
	}
	if tcp2 == "dctcp" {
		runSSHCommand(vmHostAddr, src2Port, fmt.Sprintf("sysctl net.inet.tcp.cc.dctcp.ect1=%d", dctcpEct1))
	}

	// Configure ECN
	if ecnStatus == "ecn" {
		runSSHCommand(vmHostAddr, src1Port, fmt.Sprintf("sysctl net.inet.tcp.ecn.enable=%d", tcpEcnEnable))
		runSSHCommand(vmHostAddr, src2Port, fmt.Sprintf("sysctl net.inet.tcp.ecn.enable=%d", tcpEcnEnable))
		runSSHCommand(vmHostAddr, routerPort, fmt.Sprintf("sysctl net.inet.tcp.ecn.enable=%d", tcpEcnEnable))
	} else {
		runSSHCommand(vmHostAddr, src1Port, "sysctl net.inet.tcp.ecn.enable=0")
		runSSHCommand(vmHostAddr, src2Port, "sysctl net.inet.tcp.ecn.enable=0")
		runSSHCommand(vmHostAddr, routerPort, "sysctl net.inet.tcp.ecn.enable=0")
	}
}

// Configure routers with AQM, bandwidth, and delay
func configureRouters(aqm, bw, d, e string) {
	runSSHCommand(vmHostAddr, routerPort, "ipfw -f flush")
	runSSHCommand(vmHostAddr, routerPort, fmt.Sprintf("ipfw pipe 1 config bw %s delay %s", bw, d))
	runSSHCommand(vmHostAddr, routerPort, fmt.Sprintf("ipfw sched 1 config pipe 1 type %s %s", aqm, e))
	runSSHCommand(vmHostAddr, routerPort, "ipfw queue 1 config sched 1")
	runSSHCommand(vmHostAddr, routerPort, "ipfw add 100 queue 1 ip from any to any")
}

// Start logging data
func startLog(iter int, aqm, bw, d, e string) {
	testName := fmt.Sprintf("%d_%s_%s_%s_%s", iter, aqm, bw, d, e)

	// Start siftr logging
	runSSHCommand(vmHostAddr, src1Port, fmt.Sprintf("sysctl net.inet.siftr.logfile=/root/%s_%s_src1.siftr.log", testName, tcp1))
	runSSHCommand(vmHostAddr, src1Port, "sysctl net.inet.siftr.enabled=1")
	runSSHCommand(vmHostAddr, src2Port, fmt.Sprintf("sysctl net.inet.siftr.logfile=/root/%s_%s_src2.siftr.log", testName, tcp2))
	runSSHCommand(vmHostAddr, src2Port, "sysctl net.inet.siftr.enabled=1")
	runSSHCommand(vmHostAddr, dstPort, fmt.Sprintf("sysctl net.inet.siftr.logfile=/root/%s_dsthost.siftr.log", testName))
	runSSHCommand(vmHostAddr, dstPort, "sysctl net.inet.siftr.enabled=1")

	// Start tcpdump logging
	runSSHCommand(vmHostAddr, src1Port, fmt.Sprintf("tcpdump -i em1 -w /root/%s_%s_src1.em1.pcap &", testName, tcp1))
	runSSHCommand(vmHostAddr, src2Port, fmt.Sprintf("tcpdump -i em1 -w /root/%s_%s_src2.em1.pcap &", testName, tcp2))
	runSSHCommand(vmHostAddr, dstPort, fmt.Sprintf("tcpdump -i em1 -w /root/%s_dsthost.em1.pcap &", testName))
}

// Run iperf3 client script
func clientIperf3Script(iter int, aqm, bw, d, e string) {
	testName := fmt.Sprintf("%d_%s_%s_%s_%s", iter, aqm, bw, d, e)

	// Run iperf3 clients
	runSSHCommand(vmHostAddr, src2Port, fmt.Sprintf("iperf3 -c 172.16.1.2 -t %d -p 5103 -J > iperf3_client_%s_%s.json &", duration, tcp2, testName))
	runSSHCommand(vmHostAddr, src1Port, fmt.Sprintf("iperf3 -c 172.16.1.2 -t %d -p 5101 -J -C cubic > iperf3_client_cubic_%s.json &", duration, testName))
	runSSHCommand(vmHostAddr, src1Port, fmt.Sprintf("iperf3 -c 172.16.1.2 -t %d -p 5102 -J > iperf3_client_%s_%s.json", duration, tcp1, testName))

	// Wait for the test to complete
	time.Sleep(time.Duration(duration+endWaitTime) * time.Second)
}

// End logging
func endLog() {
	// Stop siftr logging
	runSSHCommand(vmHostAddr, src1Port, "sysctl net.inet.siftr.enabled=0")
	runSSHCommand(vmHostAddr, src2Port, "sysctl net.inet.siftr.enabled=0")
	runSSHCommand(vmHostAddr, dstPort, "sysctl net.inet.siftr.enabled=0")

	// Stop tcpdump logging
	runSSHCommand(vmHostAddr, src1Port, "killall tcpdump")
	runSSHCommand(vmHostAddr, src2Port, "killall tcpdump")
	runSSHCommand(vmHostAddr, dstPort, "killall tcpdump")
}

// Create kernel data
func kernelDataCreate(iter int, aqm, bw, d, e string) {
	testName := fmt.Sprintf("%d_%s_%s_%s_%s", iter, aqm, bw, d, e)
	runSSHCommand(vmHostAddr, routerPort, fmt.Sprintf("cat /var/log/messages > kernel_data_%s.txt", testName))
}

// Truncate logs
func truncateLogs() {
	runSSHCommand(vmHostAddr, routerPort, "truncate -s 0 /var/log/messages")
}

// Cleanup previous data and processes
func cleanup() {
	runSSHCommand(vmHostAddr, src1Port, "rm -f *.siftr.log *.pcap *.out; killall iperf3")
	runSSHCommand(vmHostAddr, src2Port, "rm -f *.siftr.log *.pcap *.out; killall iperf3")
	runSSHCommand(vmHostAddr, dstPort, "rm -f *.siftr.log *.pcap *.out")
	runSSHCommand(vmHostAddr, routerPort, "rm -f *.txt")
}

// Download data from remote hosts
func dataDownload() {
	// Create local directories
	os.MkdirAll("./server_data", 0755)
	os.MkdirAll("./client1_data", 0755)
	os.MkdirAll("./client2_data", 0755)
	os.MkdirAll("./router_data", 0755)

	// Download data from dsthost
	runLocalCommand("scp", "-P", fmt.Sprintf("%d", dstPort), "-i", sshKeyPath, fmt.Sprintf("root@%s:*.siftr.log *.pcap *.out *.json", vmHostAddr), "./server_data")

	// Download data from src1host
	runLocalCommand("scp", "-P", fmt.Sprintf("%d", src1Port), "-i", sshKeyPath, fmt.Sprintf("root@%s:*.siftr.log *.pcap *.out *.json", vmHostAddr), "./client1_data")

	// Download data from src2host
	runLocalCommand("scp", "-P", fmt.Sprintf("%d", src2Port), "-i", sshKeyPath, fmt.Sprintf("root@%s:*.siftr.log *.pcap *.out *.json", vmHostAddr), "./client2_data")

	// Download data from router
	runLocalCommand("scp", "-P", fmt.Sprintf("%d", routerPort), "-i", sshKeyPath, fmt.Sprintf("root@%s:*.txt", vmHostAddr), "./router_data")
}

// Run a local command
func runLocalCommand(name string, arg ...string) {
	cmd := exec.Command(name, arg...)
	output, err := cmd.CombinedOutput()
	if err != nil {
		log.Fatalf("Command failed: %s\nOutput: %s", err, output)
	}
}

// Run an SSH command on a remote host
func runSSHCommand(host string, port int, command string) {
	config := &ssh.ClientConfig{
		User: "root",
		Auth: []ssh.AuthMethod{
			ssh.PublicKeys(readPrivateKey(sshKeyPath)),
		},
		HostKeyCallback: ssh.InsecureIgnoreHostKey(),
	}
	client, err := ssh.Dial("tcp", fmt.Sprintf("%s:%d", host, port), config)
	if err != nil {
		log.Fatalf("Failed to dial: %s", err)
	}
	defer client.Close()

	session, err := client.NewSession()
	if err != nil {
		log.Fatalf("Failed to create session: %s", err)
	}
	defer session.Close()

	output, err := session.CombinedOutput(command)
	if err != nil {
		log.Fatalf("Command failed: %s\nOutput: %s", err, output)
	}
}

// Read the private key for SSH authentication
func readPrivateKey(path string) ssh.Signer {
	keyBytes, err := os.ReadFile(path)
	if err != nil {
		log.Fatalf("Unable to read private key: %s", err)
	}
	key, err := ssh.ParsePrivateKey(keyBytes)
	if err != nil {
		log.Fatalf("Unable to parse private key: %s", err)
	}
	return key
}
