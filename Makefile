LINUX_VERSION = 2_6_39

GIT_URL_2_6_39 = https://github.com/torvalds/linux.git
GIT_BRANCH_2_6_39 = v2.6.39
DOCKERFILE_2_6_39 = centos6.Dockerfile

GIT_URL_2_6_32_754_35_1_el6 = https://github.com/kernelim/linux.git
GIT_BRANCH_2_6_32_754_35_1_el6 = kernel-2.6.32-754.35.1.el6.tar.bz2
DOCKERFILE_2_6_32_754_35_1_el6 = centos6.Dockerfile

GIT_URL_3_10_0_1160_31_1_el7 = https://github.com/kernelim/linux.git
GIT_BRANCH_3_10_0_1160_31_1_el7 = linux-3.10.0-1160.31.1.el7.tar.xz
DOCKERFILE_3_10_0_1160_31_1_el7 = centos7.Dockerfile

GIT_URL_5_4_0_65_73 = git://git.launchpad.net/~ubuntu-kernel/ubuntu/+source/linux/+git/focal
GIT_BRANCH_5_4_0_65_73 = Ubuntu-5.4.0-65.73
DOCKERFILE_5_4_0_65_73 = ubuntu2004.Dockerfile

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
		/bin/bash -c "\
			cd tmp; \
			ls -la; \
			cp /boot/config-* .config; \
			make oldconfig; \
			sed -i -e 's/^CONFIG_SYSTEM_TRUSTED_KEYS=.*/CONFIG_SYSTEM_TRUSTED_KEYS=n/g' .config; \
			sed -i -e 's/^CONFIG_DIGSIG.*/CONFIG_DIGSIG=n/g' .config; \
			sed -i -e 's/^CONFIG_MODULE_SIG=.*/CONFIG_MODULE_SIG=n/g' .config; \
			sed -i -e 's/^CONFIG_CRYPTO_SIGNATURE=.*/CONFIG_CRYPTO_SIGNATURE=n/g' .config; \
			sed -i -e 's/^CONFIG_CRYPTO_SIGNATURE_DSA=.*/CONFIG_CRYPTO_SIGNATURE_DSA=n/g' .config; \
			make KCFLAGS= WITH_GCOV=0 bzImage"
	cp linux-$(LINUX_VERSION)/arch/x86/boot/bzImage . ;

.PHONY: qemu
qemu: busybox/initrd bzImage
	qemu-system-x86_64 -kernel ./bzImage -initrd busybox/initrd --nographic \
		--append "root=/dev/ram rw console=ttyS0 rdinit=/sbin/init init=/sbin/init" 
