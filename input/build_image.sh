#!/bin/bash

export DEBOOTSTRAP_DIR=output/debootstrap
export ARCH_DIR=output
export ROOTFS_DIR=output/rootfs

case "$1" in
    arm) export DEBOOTSTRAP_ARCH=armhf
        ;;
    arm64) export DEBOOTSTRAP_ARCH=arm64
        ;;
    x86) export DEBOOTSTRAP_ARCH=i386
        ;;
    x86_64) export DEBOOTSTRAP_ARCH=amd64
        ;;
    *) echo "unsupported arch: $1"
        exit
        ;;
esac

mkdir -p $ARCH_DIR
rm -rf $ROOTFS_DIR
mkdir -p $ROOTFS_DIR
rm -rf $DEBOOTSTRAP_DIR
mkdir -p $DEBOOTSTRAP_DIR

DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true LC_ALL=C LANGUAGE=C LANG=C apt update
DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true LC_ALL=C LANGUAGE=C LANG=C apt install -y make git makedev wget sed
wget -O output/kali-archive-keyring_2020.2_all.deb http://http.kali.org/pool/main/k/kali-archive-keyring/kali-archive-keyring_2020.2_all.deb
dpkg -i output/kali-archive-keyring_2020.2_all.deb
git clone https://gitlab.com/kalilinux/packages/debootstrap.git $DEBOOTSTRAP_DIR
sed -i '/setup_devices ()/a return 0' $DEBOOTSTRAP_DIR/functions
sed -i '/setup_proc ()/a return 0' $DEBOOTSTRAP_DIR/functions
make -C $DEBOOTSTRAP_DIR devices.tar.gz
$DEBOOTSTRAP_DIR/debootstrap --foreign --arch=$DEBOOTSTRAP_ARCH --variant=minbase --include=kali-archive-keyring,perl,wget kali-rolling $ROOTFS_DIR http://http.kali.org/kali
case "$1" in
    arm32v7) cp input/qemu-arm-static $ROOTFS_DIR/usr/bin/
        ;;
    arm64v8) cp input/qemu-aarch64-static $ROOTFS_DIR/usr/bin/
        ;;
    i386) cp input/qemu-i386-static $ROOTFS_DIR/usr/bin/
        ;;
    x86_64) cp input/qemu-x86_64-static $ROOTFS_DIR/usr/bin/
        ;;
esac
wget https://archive.kali.org/archive-key.asc -O $ROOTFS_DIR/etc/apt/trusted.gpg.d/kali-archive-key.asc
tar --exclude='dev/*' -cvf $ARCH_DIR/rootfs.tar -C $ROOTFS_DIR .
