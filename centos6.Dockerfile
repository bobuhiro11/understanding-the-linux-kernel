FROM ghcr.io/buddying-inc/centos:68

ENV GO_INST_DIR /usr/local
ENV GOPATH /go
ENV PATH $PATH:$GO_INST_DIR/go/bin:$GOPATH/bin
ENV GO111MODULE auto
ENV CGO_ENABLED 0
ENV GOOS linux

RUN sed -i "s|#baseurl=|baseurl=|g" /etc/yum.repos.d/CentOS-Base.repo \
  && sed -i "s|mirrorlist=|#mirrorlist=|g" /etc/yum.repos.d/CentOS-Base.repo \
  && sed -i "s|http://mirror\.centos\.org/centos/\$releasever|https://vault\.centos\.org/6.10|g" /etc/yum.repos.d/CentOS-Base.repo \
  && sed -i "/gpgcheck/a sslverify=0" /etc/yum.repos.d/CentOS-Base.repo

RUN yum install -y gcc perl glibc-static kernel kernel-devel \
  autoconf zlib-devel zlib-static openssl-static openssl-devel curl

RUN curl -OL https://go.dev/dl/go1.17.6.linux-amd64.tar.gz \
  && tar -C $GO_INST_DIR -xzf go1.17.6.linux-amd64.tar.gz \
  && rm go1.17.6.linux-amd64.tar.gz
