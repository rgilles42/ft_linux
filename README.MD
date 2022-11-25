# Notes about LFS

Ch2		-> partitions and FS  
Ch3		-> select packages and patches + store them on new fs  
Ch4		-> setup of an appropriate working environment ⚠  
Ch5		-> About toolchain & cross-compilation  
Ch6		-> Using the toolchain  
Ch7		-> Chrooting into built base system and building additions from within  
Ch8		-> Building full LFS system  
Ch9		-> Basic system config  
Ch10	-> Setting up kernel and bootloader  
Ch11	-> LFS beyond the book  

## Host System
Had to install following packages:  
- bison (with /usr/bin/yacc being a symlink to it)  
- m4 (required by bison)  
- texinfo  

Had to `dpkg-reconfigure dash` so that `/bin/sh` would use `bash`.  
Check with local `version-check.sh`.  

## In case of host reboot
### If in Chapter 1-4 
- Procedures done as the root user after Section 2.4 need to have the LFS environment variable set FOR THE ROOT USER  
### If in Chapter 5-6
- The `/mnt/lfs` partition must be mounted => `mount_lfs.sh`  
- A `su - lfs` needs to be done; risk of installing packages to the host  
- The procedures in General Compilation Instructions are critical. If there is any doubt about installing a package, ensure any previously expanded tarballs are removed, then re-extract the package files, and complete all instructions in that section  
### If in Chapter 7-10
- The `/mnt/lfs` partition must be mounted => `mount_lfs.sh`  
- Ops from “Changing Ownership” to “Entering the Chroot Environment” must be done as root with LFS environment variable set for root  
- When entering chroot, the LFS environment variable must be set for root. The LFS variable is not used afterwards.  
- The virtual file systems must be mounted. This can be done before or after entering chroot by changing to a host virtual terminal and, as root, running the commands in Section 7.3.1, “Mounting and Populating /dev” and Section 7.3.2, “Mounting Virtual Kernel File Systems”.  

# Ch2
## Creating a disk
I created a 50GiB VDI virtual disk.  
I plug it in using `sudo qemu-nbd -c /dev/nbd0 /media/Data/VirtualBox\ VMs/ft_linux/ft_linux.vdi`

I will use the following partition scheme: 
- MBR Partition Table  
- 0.5 	GiB	- ext4 - /boot	- /dev/nbd0p1  
- 35 	GiB	- ext4 - /		- /dev/nbd0p2  
- 10.5	GiB	- ext4 - /home	- /dev/nbd0p3  
- 4 	GiB	- swap - swap	- /dev/nbd0p4  

All partitions mount with the `mount` default flags, which are `(rw,relatime)`  

I created the mountpoint of the root `/mnt/lfs` owned by `root:root` with `rwxr-x-r-x` permissions.  
Same for the mountpoints `/mnt/lfs/home` and `/mnt/lfs/boot` inside the lfs root  

I have created a swap inside the VDI but will be using the one in my current system.  
//TODO: `/sbin/swapon` on own swap once system built?

# Ch3
## Diff between -subject and +lfs:  
- +D-Bus  
- -Eudev				=>Udev (present in LFS SysV version)
- +Elfutils
- +Jinja2
- +Libffi
- +MarkupSafe
- +Meson
- +Ninja
- +OpenSSL
- +Python
- +Python Documentation
- -Sysklogd				=>Systemd (present in LFS SysV version)
- -Sysvinit				=>Systemd (present in LFS SysV version)
- +Systemd
- +Systemd Man Pages
- +Tcl Documentation
- -Udev-lfs				=>Udev (present in LFS SysV version)
- +Wheel
- +Zstd
## Tarballs
Got all the required tarballs with the `wget-list` from https://www.linuxfromscratch.org/lfs/downloads/stable-systemd/wget-list  
Removed an apparently undesired `sysvinit-304` patch from it  
As per the security advisories on 23/11/2022, the following tarballs were altered from the stable ref:  
- zlib:			from 1-2.12	to 1-2.13  
- Python3:		from 3.10.6	to 3.10.8  
- Python3-docs:	from 3.10.6	to 3.10.8  
- OpenSSL:		from 3.0.5	to 3.0.7  
- Linux:		from 5.19.2 to 6.0.8
- Inetutils:	from 2.3	to 2.4  
- Expat:		from 2.4.8	to 2.5.0  
- D-Bus:		from 1.14.0	to 1.14.4  

# CH4
Had to move the systemwide bashrc `/etc/bash.bashrc` to `/etc/bash.bashrc.NOUSE`  
# CH5, 6, 7
For each package, as user `lfs`:  
- `tar -xf <package>.tar.xz`
- Change to the directory created when the package was extracted.
- Follow the book's instructions for building the package.
- Change back to the sources directory.
- Delete the extracted source directory unless instructed otherwise.

//TODO: replace `$(hostname)` with `rgilles` in /etc/hosts which will be the future hostname of the distro.

After the end of Ch7, I unmounted all the virtual FSs, saved the $LFS root to a tar on the host, and remounted them.
# CH8
//TODO: Check back 8.2.3 for deploying inside vbox

Installed locales separately with provided list.

`pip3 install` commands in both LFS & BLFS should be run as the root user unless it's for a Python virtual environment.

I wrote these nifty functions in bash.  
```sh
myunpack () 
{ 
    tar -xf $1 && cd $(basename $1 .tar.${1##*.})
}
mygetout () 
{ 
    CURR=$(pwd);
    cd .. && rm -rf $CURR
}
```