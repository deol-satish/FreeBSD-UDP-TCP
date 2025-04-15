#!/bin/bash

# Set basic configuration values
set -x

source ./utils/settings.sh
source ./utils/router_config.sh
source ./utils/tcp_iperf3.sh
source ./utils/logger.sh
source ./utils/util.sh



configure_routers "l4s" "10Mbps" "20ms" "ecn"

# Main execution loop for running 10 iterations
for i in $(seq 1 $iterations); do
    echo "Running test iteration $i"
    run_test "$i"
    echo "Iteration $i completed"
done


# completed
echo "Test complete"
exit 0

# error
out() {
    echo "Abort test"
    exit 1
}
