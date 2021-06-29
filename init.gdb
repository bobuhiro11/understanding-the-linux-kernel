target remote localhost:10000
symbol-file vmlinux
b virtio_check_driver_offered_feature
continue
