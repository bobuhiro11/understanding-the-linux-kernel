# understanding-the-linux-kernel ![](https://github.com/bobuhiro11/understanding-the-linux-kernel/workflows/action/badge.svg)

This repository contains a set of scripts that are useful for analyzing the Linux kernel. For example, the following versions of the kernel can be built and debugged very concisely on docker without having to worry about dependent packages.

- upstream (kernel v2.6.39)
- centos6 (kernel v2.6.32-754.35.1.el6)
- centos7 (kernel v3.10.0-1160.13.1.el7)
- ubuntu20.04 (kernel v5.4.0-65.73)

These are the distributions that I am familiar with, so they are supported by default, but other versions can be applied as well.
While using this tool, I am reading the book "Understanding the Linux Kernel, 3rd Edition".

## Requirements

- linux on x86/64
- docker

## Usage

```bash
# Prepare the .config file and build the docker image as the kernel build environment.
# Also, the kernel code is downloaded here.
make prepare

# Generate a userland based on busybox. A simple shell environment and SSH server are included.
make busybox/initrd

# Change the build settings of the kernel. If you don't need it, you can skip this step.
make menuconfig

# Boot the kernel on a qemu virtual machine.
make qemu

# Connect to the virtual machine via SSH.
make ssh
```

If you want to use `gdb` to debug the kernel, replace `make qemu` with the following:

```bash
# Boot the kernel and wait for the debugger to connect
make qemu_freeze

# Connect the debugger to the virtual machine
make gdb
```

The kernel version can be specified as follows:

```bash
# centos6 (kernel v2.6.32-754.35.1.el6)
make LINUX_VERSION=2_6_32_754_35_1_el6 ...

# centos7 (kernel v3.10.0-1160.13.1.el7)
make LINUX_VERSION=3_10_0_1160_31_1_el7 ...

# ubuntu20.04 (kernel v5.4.0-65.73)
make LINUX_VERSION=5_4_0_65_73 ...
```
