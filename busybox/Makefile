BUSYBOX_VERSION = 1.33.0
CWD := $(shell cd -P -- '$(shell dirname -- "$0")' && pwd -P)

initrd: .config busybox.tar.bz2 inittab passwd rcS sshd
	tar -xf busybox.tar.bz2
	sudo cp .config busybox-$(BUSYBOX_VERSION)/.config
	sudo docker run --rm -v $(CWD)/busybox-$(BUSYBOX_VERSION):/tmp buildenv-busybox \
		/bin/bash -c "cd /tmp; make install"

	sudo cp rdinit                busybox-$(BUSYBOX_VERSION)/_install/rdinit
	sudo chmod a+x                busybox-$(BUSYBOX_VERSION)/_install/rdinit

	cd busybox-$(BUSYBOX_VERSION)/_install && find . | cpio -o -H newc | gzip > ../../initrd

root.img: .config busybox.tar.bz2 inittab passwd rcS sshd
	sudo ./create_root_img.bash $(BUSYBOX_VERSION)
	sudo ./add_files_to_root_img.bash  \
		inittab:/etc/inittab \
		passwd:/etc/passwd \
		rcS:/etc/init.d/rcS \
		profile:/etc/profile \
		udhcpc.default.script:/usr/share/udhcpc/default.script \
		sshd:/bin/sshd \

sshd: sshd.go
	sudo docker run --rm -v $(CWD):/tmp/build buildenv-busybox \
		/bin/bash -c "cd /tmp/build; \
		go build -a -ldflags '-extldflags \"-static\"' sshd.go"

busybox.tar.bz2:
	curl --retry 5 https://busybox.net/downloads/busybox-$(BUSYBOX_VERSION).tar.bz2 -o busybox.tar.bz2
