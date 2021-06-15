FROM ubuntu:20.04

RUN grep '^deb ' /etc/apt/sources.list | \
      sed 's/^deb /deb-src /g' | \
 tee /etc/apt/sources.list.d/deb-src.list
RUN apt-get update && apt-get -y install gcc make linux-image-generic flex bison openssl && apt-get -y build-dep linux 
