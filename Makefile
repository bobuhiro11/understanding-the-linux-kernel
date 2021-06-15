LINUX_VERSION = 2_6_39

GIT_URL_2_6_39 = https://github.com/torvalds/linux.git
GIT_BRANCH_2_6_39 = v2.6.39
DOCKERFILE_2_6_39 = centos6.Dockerfile

GIT_URL_3_10_0_1160_31_1_el7 = https://github.com/kernelim/linux.git
GIT_BRANCH_3_10_0_1160_31_1_el7 = linux-3.10.0-1160.31.1.el7.tar.xz
DOCKERFILE_3_10_0_1160_31_1_el7 = centos7.Dockerfile

CWD := $(shell cd -P -- '$(shell dirname -- "$0")' && pwd -P)

busybox/initrd:
	make -C busybox

bzImage:
	test -d linux-${LINUX_VERSION} \
		|| git clone ${GIT_URL_${LINUX_VERSION}} \
		--depth 1 \
		-b ${GIT_BRANCH_${LINUX_VERSION}} linux-${LINUX_VERSION}
	cat ${DOCKERFILE_${LINUX_VERSION}} | sudo docker build -t buildenv-${LINUX_VERSION} -
	sudo docker run --rm -v $(CWD)/linux-$(LINUX_VERSION):/tmp \
		buildenv-${LINUX_VERSION} \
		/bin/bash -c "cd tmp; ls -la; cp /boot/config-* .config; make oldconfig; make bzImage"
	cp linux-$(LINUX_VERSION)/arch/x86/boot/bzImage . ;

.PHONY: qemu
qemu: busybox/initrd bzImage
	qemu-system-x86_64 -kernel ./bzImage -initrd busybox/initrd --nographic \
		--append "root=/dev/ram rw console=ttyS0 rdinit=/sbin/init init=/sbin/init" 
