#!/bin/bash
LFS=/mnt/lfs
echo Unmounting $LFS...

sudo umount -v $LFS/dev/pts
sudo umount -v $LFS/{sys,proc,run,dev}

sudo umount -v $LFS/boot
sudo umount -v $LFS/home
sudo umount -v $LFS