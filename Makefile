# Locations of code used in well-known distributions
GIT_URL_2_6_39 := https://github.com/torvalds/linux.git
GIT_BRANCH_2_6_39 := v2.6.39
DOCKERFILE_2_6_39 := centos6.Dockerfile

GIT_URL_2_6_32_754_35_1_el6 := https://github.com/kernelim/linux.git
GIT_BRANCH_2_6_32_754_35_1_el6 := kernel-2.6.32-754.35.1.el6.tar.bz2
DOCKERFILE_2_6_32_754_35_1_el6 := centos6.Dockerfile

GIT_URL_3_10_0_1160_31_1_el7 := https://github.com/kernelim/linux.git
GIT_BRANCH_3_10_0_1160_31_1_el7 := linux-3.10.0-1160.31.1.el7.tar.xz
DOCKERFILE_3_10_0_1160_31_1_el7 := centos7.Dockerfile

GIT_URL_4_18_0_348_7_1_el8_5 := https://github.com/kernelim/linux.git
GIT_BRANCH_4_18_0_348_7_1_el8_5 := linux-4.18.0-348.7.1.el8_5.tar.xz
DOCKERFILE_4_18_0_348_7_1_el8_5 := centos8.Dockerfile

GIT_URL_5_4_0_65_73 := git://kernel.ubuntu.com/ubuntu/ubuntu-focal.git
GIT_BRANCH_5_4_0_65_73 := Ubuntu-5.4.0-65.73
DOCKERFILE_5_4_0_65_73 := ubuntu2004.Dockerfile

# the version of Linux you want to use and the associated information,
# which can be changed as an argument to the make command
LINUX_VERSION := 2_6_39
GIT_URL := ${GIT_URL_${LINUX_VERSION}}
DOCKERFILE := ${DOCKERFILE_${LINUX_VERSION}}
GIT_BRANCH := ${GIT_BRANCH_${LINUX_VERSION}}

CWD := $(shell cd -P -- '$(shell dirname -- "$0")' && pwd -P)
QEMU_OPTS := -kernel linux-$(LINUX_VERSION)/arch/x86/boot/bzImage -m size=512 -initrd busybox/initrd --nographic \
	--append "root=/dev/ram rw console=ttyS0 rdinit=/sbin/init init=/sbin/init nokaslr" \
	-nic user,model=virtio-net-pci,hostfwd=tcp::10022-:22 \

.PHONY: prepare
prepare:
	cat centos6.Dockerfile | sudo docker build -t buildenv-busybox -
	cat ${DOCKERFILE} | sudo docker build -t buildenv-${LINUX_VERSION} -
	test -d linux-${LINUX_VERSION} \
		|| git clone ${GIT_URL} --depth 1 -b ${GIT_BRANCH} linux-${LINUX_VERSION}
	sudo docker run --sysctl net.ipv6.conf.all.disable_ipv6=1 --cap-add=NET_ADMIN \
		--rm -v $(CWD)/linux-$(LINUX_VERSION):/tmp \
		buildenv-${LINUX_VERSION} \
		/bin/bash -c "\
		cd tmp; \
		ls -la; \
		cp /boot/config* .config; \
		make oldconfig; \
		sed -i -e 's/^CONFIG_SYSTEM_TRUSTED_KEYS=.*/CONFIG_SYSTEM_TRUSTED_KEYS=n/g' .config; \
		sed -i -e 's/^CONFIG_DIGSIG.*/CONFIG_DIGSIG=n/g' .config; \
		sed -i -e 's/^CONFIG_MODULE_SIG=.*/CONFIG_MODULE_SIG=n/g' .config; \
		sed -i -e 's/^CONFIG_CRYPTO_SIGNATURE=.*/CONFIG_CRYPTO_SIGNATURE=n/g' .config; \
		sed -i -e 's/^CONFIG_CRYPTO_SIGNATURE_DSA=.*/CONFIG_CRYPTO_SIGNATURE_DSA=n/g' .config; \
		sed -i -e 's/^CONFIG_DEBUG_INFO_BTF=.*/CONFIG_DEBUG_INFO_BTF=n/g' .config; \
		sed -i -e 's/^CONFIG_VIRTIO_NET=.*/CONFIG_VIRTIO_NET=y/g' .config; \
		sed -i -e 's/^CONFIG_VIRTIO_RING=.*/CONFIG_VIRTIO_RING=y/g' .config; \
		sed -i -e 's/^CONFIG_VIRTIO_PCI=.*/CONFIG_VIRTIO_PCI=y/g' .config"

.PHONY: busybox/initrd
busybox/initrd:
	make -C busybox initrd

.PHONY: menuconfig
menuconfig:
	make -C linux-${LINUX_VERSION} menuconfig

.PHONY: bzImage
bzImage:
	sudo docker run --sysctl net.ipv6.conf.all.disable_ipv6=1 --cap-add=NET_ADMIN \
		--rm -v $(CWD)/linux-$(LINUX_VERSION):/tmp \
		buildenv-${LINUX_VERSION} \
		/bin/bash -c "cd tmp; make -j2 V=0 KCFLAGS= WITH_GCOV=0 bzImage"

.PHONY: qemu
qemu:
	qemu-system-x86_64 $(QEMU_OPTS)

.PHONY: qemu_freeze
qemu_freeze:
	qemu-system-x86_64 $(QEMU_OPTS) -gdb tcp::10000 -S

.PHONY: gdb
gdb:
	gdb --directory=./linux-${LINUX_VERSION} ./linux-${LINUX_VERSION}/vmlinux \
		-ex 'target remote localhost:10000' \
		-ex 'b page_fault' \
		-ex 'continue' \

.PHONY: ssh
ssh:
	ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@localhost -p 10022
