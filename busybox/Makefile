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
	sudo ./create_root_img.bash $(CWD) $(BUSYBOX_VERSION)

sshd: sshd.go
	sudo docker run --rm -v $(CWD):/tmp buildenv-busybox \
		/bin/bash -c "cd /tmp; \
		go get github.com/kr/pty golang.org/x/crypto/ssh; \
		go build -a -ldflags '-extldflags \"-static\"' sshd.go"

busybox.tar.bz2:
	curl --retry 5 https://busybox.net/downloads/busybox-$(BUSYBOX_VERSION).tar.bz2 -o busybox.tar.bz2
