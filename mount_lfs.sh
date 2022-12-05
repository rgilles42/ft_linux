#!/bin/bash
LFS=/mnt/lfs
echo Mounting /dev/nbd0 on $LFS
sudo mount -v -t ext4 /dev/nbd0p2 $LFS
sudo mount -v -t ext4 /dev/nbd0p1 $LFS/boot
sudo mount -v -t ext4 /dev/nbd0p3 $LFS/home

sudo mount -v --bind /dev $LFS/dev
sudo mount -v --bind /dev/pts $LFS/dev/pts
sudo mount -vt proc proc $LFS/proc
sudo mount -vt sysfs sysfs $LFS/sys
sudo mount -vt tmpfs tmpfs $LFS/run