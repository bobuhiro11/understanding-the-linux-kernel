#!/bin/bash

cwd=$(dirname -- "$0")

if [ ! -f "${cwd}/root.img" ]; then
  echo "${cwd}/root.img cannot found."
  exit 1
fi


loop_dev=$(kpartx -av root.img | awk '{print $3}')
mkdir -p /tmp/rootfs
mount /dev/mapper/"${loop_dev}" /tmp/rootfs

for file in "$@"
do
    src="${cwd}/$(echo "$file" | awk -F: '{print $1}')"
    dst="/tmp/rootfs/$(echo "$file" | awk -F: '{print $2}')"
    echo "copy $src -> $dst"
    cp "$src" "$dst"
done

umount /tmp/rootfs
kpartx -d root.img
