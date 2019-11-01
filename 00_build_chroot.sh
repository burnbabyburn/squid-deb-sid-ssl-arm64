#!/bin/bash
# Helge custom script to build latest squid package from debian-testing with ssl interception 

#######################################################################################
#Init
chroot_exec() {
  # Exec command in chroot
  LANG=C LC_ALL=C DEBIAN_FRONTEND=noninteractive chroot "$CHROOTD" "$@"
}

# Create temporary directory for chroot
#temp_dir=$(mktemp -d)
export BASE=$(pwd)
export CHROOTD="$BASE"/debian-arm64

#squid 4.8-1 patch needed to compile with gcc9 in current debian package
export RELEASE=testing

#Outputdir for deb packages
export OUTD=/home/helge/selfbuild-debs
#######################################################################################
#Setup Chroot
# Install arm64 env
script -c 'http_proxy=http://127.0.0.1:3142 sudo qemu-debootstrap --arch=arm64 --keyring /usr/share/keyrings/debian-archive-keyring.gpg --variant=buildd --include=bash,apt-utils,ca-certificates $RELEASE $CHROOTD http://ftp.debian.org/debian'

# Mount required filesystems
mount -t proc none "$CHROOTD/proc"
mount -t sysfs none "$CHROOTD/sys"

# Mount pseudo terminal slave if supported by Debian release
if [ -d "$CHROOTD/dev/pts" ] ; then
  mount --bind /dev/pts "$CHROOTD/dev/pts"
fi
