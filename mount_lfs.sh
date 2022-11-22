#!/bin/bash
echo Mounting /dev/nbd0 on $LFS
sudo mount -v -t ext4 /dev/nbd0p2 $LFS
sudo mount -v -t ext4 /dev/nbd0p1 $LFS/boot
sudo mount -v -t ext4 /dev/nbd0p3 $LFS/home