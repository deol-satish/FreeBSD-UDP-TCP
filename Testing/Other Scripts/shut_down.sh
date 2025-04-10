#!/bin/bash
set -x

source ../utils/settings.sh

ssh -i ~/.ssh/mptcprootkey root@$router_ipaddr "shutdown -p now" >/dev/null &
ssh -i ~/.ssh/mptcprootkey root@$client1_ipaddr "shutdown -p now" >/dev/null &
ssh -i ~/.ssh/mptcprootkey root@$client2_ipaddr "shutdown -p now" >/dev/null &
ssh -i ~/.ssh/mptcprootkey root@$server_ipaddr "shutdown -p now" >/dev/null &

echo "done"
exit 0

# error
out() {
    echo "Abort test"
    exit 1
}

