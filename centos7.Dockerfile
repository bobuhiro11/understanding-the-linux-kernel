FROM ghcr.io/pandemonium1986/centos7:latest

RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-* && \
    yum -y update && yum clean all

RUN yum install -y gcc perl glibc-static make flex bison kernel-devel \
  kernel elfutils-libelf-devel openssl
