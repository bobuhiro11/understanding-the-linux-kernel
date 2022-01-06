FROM ghcr.io/pandemonium1986/centos8:latest

RUN dnf install -y dnf-plugins-core \
  && yum config-manager --set-enabled powertools \
  && dnf install -y gcc perl glibc-static make flex bison kernel-devel \
    kernel elfutils-libelf-devel openssl-devel diffutils bc

RUN cp /lib/modules/*/config /boot/config
