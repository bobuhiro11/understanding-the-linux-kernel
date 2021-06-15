FROM centos:7

RUN yum install -y gcc perl glibc-static make flex bison kernel-devel kernel libelf-dev openssl
