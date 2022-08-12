FROM ghcr.io/pandemonium1986/centos7:latest

RUN yum install -y gcc perl glibc-static make flex bison kernel-devel \
  kernel elfutils-libelf-devel openssl
