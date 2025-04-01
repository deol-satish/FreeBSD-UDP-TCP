#!/bin/csh
#
# Copy the config files onto each VM, 
#
# Assumes private/public keys have been copied already, is executed on the
# VM Host machine

scp -P 3322 -p -i ~/.ssh/mptcprootkey confs/server/rc.conf root@192.168.56.1:/etc/
scp -P 3322 -p -i ~/.ssh/mptcprootkey confs/server/ipfw.rules root@192.168.56.1:/etc/
scp -P 3322 -p -i ~/.ssh/mptcprootkey confs/server/loader.conf root@192.168.56.1:/boot/



scp -P 3323 -p -i ~/.ssh/mptcprootkey confs/client1/rc.conf root@192.168.56.1:/etc/
scp -P 3323 -p -i ~/.ssh/mptcprootkey confs/client1/ipfw.rules root@192.168.56.1:/etc/
scp -P 3323 -p -i ~/.ssh/mptcprootkey confs/client1/loader.conf root@192.168.56.1:/boot/



scp -P 4422 -p -i ~/.ssh/mptcprootkey confs/router/rc.conf root@192.168.56.1:/etc/
scp -P 4422 -p -i ~/.ssh/mptcprootkey confs/router/ipfw.rules root@192.168.56.1:/etc/
scp -P 4422 -p -i ~/.ssh/mptcprootkey confs/router/loader.conf root@192.168.56.1:/boot/


scp -P 4423 -p -i ~/.ssh/mptcprootkey confs/client2/rc.conf root@192.168.56.1:/etc/
scp -P 4423 -p -i ~/.ssh/mptcprootkey confs/client2/ipfw.rules root@192.168.56.1:/etc/
scp -P 4423 -p -i ~/.ssh/mptcprootkey confs/client2/loader.conf root@192.168.56.1:/boot/



echo "done"
exit 0



