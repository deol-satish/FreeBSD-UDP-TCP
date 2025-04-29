#!/bin/bash

# Set basic configuration values
set -x

source ./utils/settings.sh
source ./utils/router_config.sh
source ./utils/tcp_iperf3.sh
source ./utils/logger.sh
source ./utils/util.sh
source ./utils/udp_iperf3.sh

data_download
exit 0

# error
out() {
    echo "Abort test"
    exit 1
}

data_download
