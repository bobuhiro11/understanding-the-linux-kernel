LINUX_VERSION = 2.6.39.4

busybox/initrd:
	make -C busybox

linux.tar.xz:
	curl --retry 5 https://cdn.kernel.org/pub/linux/kernel/v2.6/linux-$(LINUX_VERSION).tar.xz \
		-o linux.tar.xz

bzImage: linux.tar.xz Dockerfile
	tar Jxf ./linux.tar.xz
	cat Dockerfile | sudo docker build -t centos610-buildenv -
	sudo docker run --rm -v $(PWD)/linux-$(LINUX_VERSION):/tmp centos610-buildenv \
		/bin/bash -c "cd tmp; ls -la ;make defconfig; make"
	cp linux-$(LINUX_VERSION)/arch/x86/boot/bzImage . ;

.PHONY: qemu
qemu: busybox/initrd bzImage
	qemu-system-x86_64 -kernel ./bzImage -initrd busybox/initrd --nographic \
		--append "root=/dev/ram rw console=ttyS0 rdinit=/sbin/init init=/sbin/init" 
