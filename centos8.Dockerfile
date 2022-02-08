FROM ghcr.io/pandemonium1986/centos8:latest

RUN sed -i 's|mirrorlist|#mirrorlist|g' /etc/yum.repos.d/CentOS-Linux-* \
  && sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-Linux-* \
  && dnf install -y dnf-plugins-core \
  && yum config-manager --set-enabled powertools \
  && dnf install -y gcc perl glibc-static make flex bison kernel-devel \
    kernel elfutils-libelf-devel openssl-devel diffutils bc

RUN cp /lib/modules/*/config /boot/config
