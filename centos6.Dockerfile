FROM ghcr.io/buddying-inc/centos:68

RUN sed -i "s|#baseurl=|baseurl=|g" /etc/yum.repos.d/CentOS-Base.repo \
  && sed -i "s|mirrorlist=|#mirrorlist=|g" /etc/yum.repos.d/CentOS-Base.repo \
  && sed -i "s|http://mirror\.centos\.org/centos/\$releasever|https://vault\.centos\.org/6.10|g" /etc/yum.repos.d/CentOS-Base.repo

RUN yum install -y gcc perl glibc-static kernel kernel-devel \
  autoconf zlib-devel zlib-static openssl-static openssl-devel
