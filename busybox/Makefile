BUSYBOX_VERSION = 1.33.0
CWD := $(shell cd -P -- '$(shell dirname -- "$0")' && pwd -P)

initrd: .config busybox.tar.bz2 inittab passwd rcS sshd
	tar -xf busybox.tar.bz2
	sudo cp .config busybox-$(BUSYBOX_VERSION)/.config
	sudo docker run --rm -v $(CWD)/busybox-$(BUSYBOX_VERSION):/tmp buildenv-busybox \
		/bin/bash -c "cd /tmp; make install"
	sudo mkdir -p busybox-$(BUSYBOX_VERSION)/_install/etc/init.d
	sudo mkdir -p busybox-$(BUSYBOX_VERSION)/_install/proc
	sudo mkdir -p busybox-$(BUSYBOX_VERSION)/_install/sys
	sudo mkdir -p busybox-$(BUSYBOX_VERSION)/_install/dev/pts
	sudo mkdir -p busybox-$(BUSYBOX_VERSION)/_install/bin
	sudo mkdir -p busybox-$(BUSYBOX_VERSION)/_install/usr/share/udhcpc
	sudo mount -t devpts none busybox-$(BUSYBOX_VERSION)/_install/dev/pts

	sudo mknod -m 0666 busybox-$(BUSYBOX_VERSION)/_install/dev/ptmx c 5 2 || true
	sudo mknod -m 0666 busybox-$(BUSYBOX_VERSION)/_install/dev/tty c 5 0 || true
	sudo mknod -m 0666 busybox-$(BUSYBOX_VERSION)/_install/dev/random c 1 8 || true
	sudo mknod -m 0666 busybox-$(BUSYBOX_VERSION)/_install/dev/urandom c 1 9 || true
	sudo mknod busybox-$(BUSYBOX_VERSION)/_install/dev/null c 1 3 || true
	sudo mknod busybox-$(BUSYBOX_VERSION)/_install/dev/zero c 1 5 || true
	sudo mknod busybox-$(BUSYBOX_VERSION)/_install/dev/fb0 c 29 0 || true
	sudo mknod busybox-$(BUSYBOX_VERSION)/_install/dev/sda b 8 0 || true
	sudo mknod busybox-$(BUSYBOX_VERSION)/_install/dev/sda1 b 8 1 || true
	sudo mknod busybox-$(BUSYBOX_VERSION)/_install/dev/sda2 b 8 2 || true
	sudo mknod busybox-$(BUSYBOX_VERSION)/_install/dev/sda3 b 8 3 || true
	sudo mknod busybox-$(BUSYBOX_VERSION)/_install/dev/sda4 b 8 4 || true
	sudo mknod busybox-$(BUSYBOX_VERSION)/_install/dev/sr0 b 11 0 || true
	sudo mknod busybox-$(BUSYBOX_VERSION)/_install/dev/tty c 5 0 || true
	sudo mknod busybox-$(BUSYBOX_VERSION)/_install/dev/tty0 c 4 0 || true
	sudo mknod busybox-$(BUSYBOX_VERSION)/_install/dev/tty1 c 4 1 || true
	sudo mknod busybox-$(BUSYBOX_VERSION)/_install/dev/tty2 c 4 2 || true
	sudo mknod busybox-$(BUSYBOX_VERSION)/_install/dev/tty3 c 4 3 || true
	sudo mknod busybox-$(BUSYBOX_VERSION)/_install/dev/tty4 c 4 4 || true
	sudo mknod busybox-$(BUSYBOX_VERSION)/_install/dev/ttyAMA0 c 204 64 || true
	sudo mknod busybox-$(BUSYBOX_VERSION)/_install/dev/ttyAMA1 c 204 65 || true
	sudo mknod busybox-$(BUSYBOX_VERSION)/_install/dev/ttyS0 c 4 64 || true
	sudo mknod busybox-$(BUSYBOX_VERSION)/_install/dev/ttyS1 c 4 65 || true
	sudo mknod busybox-$(BUSYBOX_VERSION)/_install/dev/input/mouse0 c 13 32 || true
	sudo mknod busybox-$(BUSYBOX_VERSION)/_install/dev/input/mouse1 c 13 33 || true
	sudo mknod busybox-$(BUSYBOX_VERSION)/_install/dev/input/mouse2 c 13 34 || true
	sudo mknod busybox-$(BUSYBOX_VERSION)/_install/dev/input/mouse3 c 13 35 || true
	sudo mknod busybox-$(BUSYBOX_VERSION)/_install/dev/input/misc c 13 63 || true
	sudo mknod busybox-$(BUSYBOX_VERSION)/_install/dev/input/event0 c 13 64 || true
	sudo mknod busybox-$(BUSYBOX_VERSION)/_install/dev/input/event1 c 13 65 || true
	sudo mknod busybox-$(BUSYBOX_VERSION)/_install/dev/input/event2 c 13 66 || true
	sudo mknod busybox-$(BUSYBOX_VERSION)/_install/dev/input/event3 c 13 67 || true
	sudo mknod busybox-$(BUSYBOX_VERSION)/_install/dev/input/event4 c 13 68 || true

	sudo cp inittab               busybox-$(BUSYBOX_VERSION)/_install/etc/inittab
	sudo cp passwd                busybox-$(BUSYBOX_VERSION)/_install/etc/passwd
	sudo cp rcS                   busybox-$(BUSYBOX_VERSION)/_install/etc/init.d/rcS
	sudo cp profile               busybox-$(BUSYBOX_VERSION)/_install/etc/profile
	sudo cp udhcpc.default.script busybox-$(BUSYBOX_VERSION)/_install/usr/share/udhcpc/default.script

	# custom sshd server
	sudo cp sshd                  busybox-$(BUSYBOX_VERSION)/_install/bin/
	yes | sudo ssh-keygen -t rsa -f busybox-$(BUSYBOX_VERSION)/_install/id_rsa -q -N ""
	sudo chmod a+r busybox-$(BUSYBOX_VERSION)/_install/id_rsa

	cd busybox-$(BUSYBOX_VERSION)/_install && find . | cpio -o -H newc | gzip > ../../initrd

sshd: sshd.go
	sudo docker run --rm -v $(CWD):/tmp buildenv-busybox \
		/bin/bash -c "cd /tmp; \
		go get github.com/kr/pty golang.org/x/crypto/ssh; \
		go build -a -ldflags '-extldflags \"-static\"' sshd.go"

busybox.tar.bz2:
	curl --retry 5 https://busybox.net/downloads/busybox-$(BUSYBOX_VERSION).tar.bz2 -o busybox.tar.bz2
