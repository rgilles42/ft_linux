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
# Ch9
## Network
I registered the Virtual NIC's MAC address under the name `eth0`  
I created the conf so that DHCP is setup over Static IP.  
I'm counting on systemd-resolved to fetch DNS info from DHCP so I'm not creating an `/etc/resolv.conf` file  
I'm using the `rgilles` hostname.  
My hosts file is:  
```
# Begin /etc/hosts
127.0.0.1 localhost localhost.localdomain
127.0.1.1 rgilles.localdomain rgilles
::1 localhost localhost.localdomain ip6-localhost ip6-loopback
# End /etc/hosts
```  
## Clock
VirtualBox is set up to advertise UTC time so I'm not touching anything.
# Ch10
## Linux
I ran `make defconfigs`  
I set `-rgilles` to Local version  
I followed the things recommended by LFS, and added a few things that looked good and safe, with virtualization in mind.  
//TODO: ADD CONFIG_INPUT_MOUSEDEV_PSAUX
# Ch11
`/etc/profile` loads anything in `/etc/profile.d`
`/root/.profile` loads `./.bashrc`
Added `.profile` and `.bashrc` in `/etc/skel`
# Beyond LFS
## Preliminary
Fetch the systemd-units archive. 
## wget
            libtasn
        p11-kit
    make-ca
wget
## GPM
## Lynx
## Sudo
Members can run as su if in group `wheel`
## Openssh
Path to `xauth` set to `usr/bin/xauth` in `/etc/ssh/sshd_config`
## KDE
### extra-cmake-modules
        libuv
            libxml2
        nghttp2
        libarchive
        cURL
    CMake
extra-cmake-modules
### Phonon
            docbook-xsl-nons
                sgml-common
                UnZip
            docbook-xml
        libxslt
        PCRE
    GLib
    shared-mime-info
    desktop-file-utils
    gobject-introspection
                    libpng
                    which
                        Graphite2
                        ICU
                    HarfBuzz (⚠️)
                FreeType
            Fontconfig
                        util-macros
                    xorgproto
                libXau
                xcb-proto
                libXdmcp
            libxcb
        Xorg Libraries
        dbus
                    libogg
                libvorbis
                FLAC
                Opus
            alsa-lib                //TODO:Check kernel module status
            Speex
            libsndfile
                Linux-PAM
            libcap                  //TODO: Check the 'Additionnaly'
        PulseAudio
            xcb-util
        xcb-util-image
        xcb-util-keysims
        xcb-util-renderutil
        xcb-util-wm
                Nettle
                libunistring
            GnuTLS
            libusb
                xmlto
            xdg-utils               //TODO: Install Xorg Apps at some time
                lcms
                            libssh2
                            llvm
                        rustc
                    JS
                polkit
                SQLite
                libgudev
                    Graphviz
                Vala
                    usbutils
                        itstool
                        Pygments
                    GTK-Doc
                libgusb
                Systemd
            colord
        Cups                    //TODO: install cups-filters at some time
        mtdev
        pcre2
            yasm
        libjpeg-turbo
        JasPer
        libmng
        libtiff
            SDL
        libwebp
        wayland
            wayland-protocols
            xkeyboard-config
        libxkbcommon
            libdrm
            Mako
            libvdpau
            libva
        Mesa
        libva
            gstreamer
            CDParanoia
            iso-codes (4.12.0)
            libtheora
                FriBidi
                    Pixman
                Cairo
            Pango
        gst-plugin-base
    Qt
Phonon
### phonon-backend-gstreamer
        NASM
        mpg123
        libvpx
                libidn2
            libpsl
                gsettings-desktop-schemas
            glib-networking
        libsoup
        LAME
            docutils
        gdk-pixbuf
        librsvg
    gst-plugin-good
        libdvdread
        libdvdnav
        SoundTouch
    gst-plugin-bad
        liba52
        x264
    gst-plugin-ugly
phonon-backend-gstreamer
### phonon-backend-vlc
Skipped due to complexity of vlc
### Polkit-Qt
### libdbusmenu-qt
### Plasma-wayland-protocols
### KDE frameworks
    Boost
    giflib
    libepoxy
        libgpg-error
    libgcrypt
    libical
    lmdb
    Qca
    qrencode
        Test::Needs
    URI
    Aspell
    Aspell EN Dictionnary
        libdaemon
            ATK-2
            hicolor-icon-theme
        GTK+-2
        libglade
                at-spi2-core
            at-spi2-atk
            adwaita-icon-theme
            sassc
        GTK+-3
    Avahi
        jansson
        libndp
            libnl
        wpa_supplicant          //TODO: kernel
        UPower                  //TODO: kernel
            PyCairo
        PyGObject
            NSPR
        nss
            popt
            slang
        newt
        DHCP                    //TODO: install systemdunit and enable?, switch off systemd-networkd
        iptables                //TODO: kernel //TODO: config + systemd?
        oxygen font
        noto font
    NetworkManager              //TODO: systemd?
        libyaml
    pyyaml (!)
        lxml
    breeze-icons
    oxygen-icons
frameworks
### Ark
    cpio
    p7zip
    UnRar
    Zip
### KMix
    libcanberra
kmix
### kio-extras
    kdsoap
kio-extras
### konsole
### libkexiv2
    exiv2
### Okular
        OpenJPEG
    Poppler
### 