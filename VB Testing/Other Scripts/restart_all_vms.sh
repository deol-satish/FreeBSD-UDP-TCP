#!/bin/bash
set -x

source ../utils/settings.sh

ssh -p "$router1port" -i "$sshkeypath" root@"$vmhostaddr" "shutdown -r now" &
ssh -p "$src1port" -i "$sshkeypath" root@"$vmhostaddr" "shutdown -r now" &
ssh -p "$src2port" -i "$sshkeypath" root@"$vmhostaddr" "shutdown -r now" &
ssh -p "$dsthostport" -i "$sshkeypath" root@"$vmhostaddr" "shutdown -r now" &

echo "done"
exit 0

# error
out() {
    echo "Abort test"
    exit 1
}

