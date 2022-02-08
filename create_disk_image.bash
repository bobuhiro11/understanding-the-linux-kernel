#!/bin/bash -x

cmdline=${1:-""}
output_file=${2:-"disk.img"}

# create disk
qemu-img create ${output_file} 512M
sgdisk -n "0::+1M"  -t 0:EF02 -c 0:"BIOS boot partition"  ${output_file}
sgdisk -n "0::+50M" -t 0:EF00 -c 0:"EFI system partition" ${output_file}
sgdisk -n "0::"     -t 0:8300 -c 0:"Linux filesystem"     ${output_file}
sgdisk -p ${output_file}
kpartx -av ${output_file}

# make filesystem
N=$(kpartx -l ${output_file} | awk '{print $5}' | head -n 1 | grep -o -E '[0-9]*')
mkfs.fat -F 32 /dev/mapper/loop${N}p2
mkfs.ext4 /dev/mapper/loop${N}p3

# mount
mkdir -p /tmp/efi/ /tmp/rootfs/
mount /dev/mapper/loop${N}p2 /tmp/efi
mount /dev/mapper/loop${N}p3 /tmp/rootfs

# copy initrd
cp busybox/initrd /tmp/rootfs/initrd
mkdir -p /tmp/rootfs/boot/grub /tmp/efi/EFI/grub

# copy kernel & setup menuentry
for path in $(find linux-*/arch/x86/boot/bzImage)
do
  name=$(echo $path | awk -F\/ '{print $1}')
  cp $path /tmp/rootfs/vmlinuz-${name}

  if [[  $name == "linux-2_6"* ]]
  then
    linux_inst="legacy_kernel"
    initrd_inst="legacy_initrd"
  else
    linux_inst="linux"
    initrd_inst="initrd"
  fi

  cat << EOF | tee -a /tmp/rootfs/boot/grub/grub.cfg | tee -a /tmp/efi/EFI/grub/grub.cfg
  menuentry 'Linux, Busybox, ${name}' {
    $linux_inst /vmlinuz-${name} ${cmdline}
    $initrd_inst /initrd
  }
EOF
done

# grub install
grub-install --root-directory=/tmp/rootfs --target i386-pc /dev/loop${N}

# clean up
umount /tmp/rootfs/
umount /tmp/efi/
rm -rf /tmp/rootfs/
kpartx -d ${output_file}
