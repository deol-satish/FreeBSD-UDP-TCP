# FreeBSD 14.1 Setup Instructions

## Partitioning and Filesystem Configuration
1. Use **UFS** with **MBR partitioning** for storage.
2. Select the **NTFS** filesystem with the `ntfs` and `ntfs-sync` options to enable synchronized timing.
3. During login, when prompted to add users to other groups, type `wheel`.

## Installing Essential Packages
Run the following commands to install the necessary packages:
```sh
pkg install git
pkg install iperf3
pkg install rsync
pkg install nano
```

## VMware VM Network Setup
1. Install FreeBSD using **bridged networking** first.
2. If you encounter a `DHCP lease failed` error, switch to **NAT networking**.
3. If the problem persists, restart the VMware network service using the **VMware Network Editor**.

---
This guide ensures a smooth setup of FreeBSD 14.1 with proper partitioning, package installations, and network configurations in VMware.

## Installin Custom-Built Kernel
```sh
git clone https://github.com/deol-satish/FreeBSD-L4S-SRC.git
cd FreeBSD-L4S-SRC
git checkout UDP-Dev

make -j2 buildworld 
```

IF you get Error while buildowlrd then increase swapsize to atleast 2GB
```sh
git clone https://github.com/deol-satish/FreeBSD-L4S-SRC.git; cd FreeBSD-L4S-SRC; git checkout L4S-141; make -j2 buildworld 
```
Next , if you get error then remove DKERNFAST
```sh
make buildkernel -j4 -DKERNFAST KERNCONF=L4SKERNEL
make installkernel -j4 -DKERNFAST KERNCONF=L4SKERNEL
```
```sh
make buildkernel -j4 KERNCONF=L4SKERNEL
shutdown -r now

make installkernel -j4 KERNCONF=L4SKERNEL
shutdown -r now
```

git checkout origin/dualpi2141;git pull origin dualpi2141
git checkout origin/L4S-ECT1;git pull origin L4S-ECT1
make clean; make -j12 buildworld 

git clone https://github.com/deol-satish/FreeBSD-L4S-SRC.git; cd FreeBSD-L4S-SRC; git checkout L4S-DEV-142;make clean; make -j4 buildworld 

git pull origin L4S-141

git clone https://github.com/deol-satish/FreeBSD-L4S-SRC.git; 
git fetch --all; git checkout L4S-141;make clean; make -j4 buildworld 

git checkout L4S-141;make -j4 buildworld 

make -j6 buildworld 

make buildkernel -j2 KERNCONF=L4SKERNEL

make clean; make -j6 buildworld 
make buildkernel -j6 KERNCONF=L4SKERNEL;

sysctl net.inet.ip.dummynet