#!/bin/bash
set -x

source ./utils/settings.sh

ssh -i ~/.ssh/mptcprootkey root@$router_ipaddr "shutdown -r now" >/dev/null &
ssh -i ~/.ssh/mptcprootkey root@$client1_ipaddr "shutdown -r now" >/dev/null &
ssh -i ~/.ssh/mptcprootkey root@$client2_ipaddr "shutdown -r now" >/dev/null &
ssh -i ~/.ssh/mptcprootkey root@$server_ipaddr "shutdown -r now" >/dev/null &

echo "done"
exit 0

