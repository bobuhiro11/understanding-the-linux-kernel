#!/bin/bash -x

cwd=$(dirname -- "$0")
busybox_version=$1

qemu-img create root.img 512M
parted root.img --script 'mklabel msdos mkpart primary 1M -1s print quit'

loop_dev=$(kpartx -av root.img | awk '{print $3}')
mkfs.ext2 /dev/mapper/"${loop_dev}"
mkdir -p /tmp/rootfs
mount /dev/mapper/"${loop_dev}" /tmp/rootfs

tar -xf busybox.tar.bz2
cp .config "${cwd}"/busybox-"${busybox_version}"/.config
docker run --rm -v "${cwd}"/busybox-"${busybox_version}":/tmp buildenv-busybox \
	/bin/bash -c "cd /tmp; make install"

cp -R ./busybox-"${busybox_version}"/_install/* /tmp/rootfs/
touch /tmp/rootfs/this-directory-is-in-vda1

mkdir -p /tmp/rootfs/{etc/init.d,usr/share/udhcpc}

# custom sshd server
yes | ssh-keygen -t rsa -f /tmp/rootfs/id_rsa -q -N ""
chmod a+r /tmp/rootfs/id_rsa

umount /tmp/rootfs
kpartx -d root.img
