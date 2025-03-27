For FreeBSD 14.1, follow these instructions:

1. Use UFS with MBR partitioning for storage.
2. Select the NTFS filesystem with the `ntfs` and `ntfs-sync` options to enable synchronized timing.
3. During login, type `wheel` when prompted to add users to other groups.


Install packages:
pkg install git
pkg install iperf3
pkg install rsync
pkg install nano

On VMware VM: Installed with bridge first and then go with NAT
and if problem arises, restart vmware network in vmware network editor
