#!/bin/bash -x

CWD=$1
DOCKERFILE=$2
LINUX_VERSION=$3
GIT_URL=$4
GIT_BRANCH=$5

wait_and_retry() {
  local retries="$1"
  local wait="$2"
  local command="${*:3}"

  echo "retries=$retries wait=$wait command=$command"

  $command
  local exit_code=$?

  if [[ $exit_code -ne 0 && $retries -gt 0 ]]; then
    sleep "$wait"
    wait_and_retry $((retries - 1)) "$wait" "$command"
  else
    return $exit_code
  fi
}

sudo bash -c "docker build -t buildenv-busybox - < centos6.Dockerfile"
sudo bash -c "docker build -t \"buildenv-${LINUX_VERSION}\" - < $DOCKERFILE"
test -d "linux-${LINUX_VERSION}" \
  || wait_and_retry 5 10 git clone "${GIT_URL}" --depth 1 -b "${GIT_BRANCH}" "linux-${LINUX_VERSION}"
sudo docker run --sysctl net.ipv6.conf.all.disable_ipv6=1 --cap-add=NET_ADMIN \
  --rm -v "${CWD}/linux-${LINUX_VERSION}:/tmp" \
  "buildenv-${LINUX_VERSION}" \
  /bin/bash -c "\
  cd tmp; \
  ls -la; \
  cp /boot/config* .config; \
  make oldconfig; \
  sed -i -e 's/^CONFIG_SYSTEM_TRUSTED_KEYS=.*/CONFIG_SYSTEM_TRUSTED_KEYS=n/g' .config; \
  sed -i -e 's/^CONFIG_DIGSIG.*/CONFIG_DIGSIG=n/g' .config; \
  sed -i -e 's/^CONFIG_MODULE_SIG=.*/CONFIG_MODULE_SIG=n/g' .config; \
  sed -i -e 's/^CONFIG_CRYPTO_SIGNATURE=.*/CONFIG_CRYPTO_SIGNATURE=n/g' .config; \
  sed -i -e 's/^CONFIG_CRYPTO_SIGNATURE_DSA=.*/CONFIG_CRYPTO_SIGNATURE_DSA=n/g' .config; \
  sed -i -e 's/^CONFIG_DEBUG_INFO_BTF=.*/CONFIG_DEBUG_INFO_BTF=n/g' .config; \
  sed -i -e 's/^CONFIG_VIRTIO_NET=.*/CONFIG_VIRTIO_NET=y/g' .config; \
  sed -i -e 's/^CONFIG_VIRTIO_RING=.*/CONFIG_VIRTIO_RING=y/g' .config; \
  sed -i -e 's/^CONFIG_VIRTIO_BLK=.*/CONFIG_VIRTIO_BLK=y/g' .config; \
  sed -i -e 's/^CONFIG_BLK_DEV=.*/CONFIG_BLK_DEV=y/g' .config; \
  sed -i -e 's/^CONFIG_EXT2_FS=.*/CONFIG_EXT2_FS=y/g' .config; \
  sed -i -e 's/^CONFIG_EXT3_FS=.*/CONFIG_EXT3_FS=y/g' .config; \
  sed -i -e 's/^CONFIG_EXT4_FS=.*/CONFIG_EXT4_FS=y/g' .config; \
  sed -i -e 's/^CONFIG_SYSTEM_REVOCATION_KEYS=.*/CONFIG_SYSTEM_REVOCATION_KEYS=""/g' .config; \
  sed -i -e 's/^CONFIG_MODVERSIONS=.*/CONFIG_MODVERSIONS=n/g' .config; \
  sed -i -e 's/^CONFIG_VIRTIO_PCI=.*/CONFIG_VIRTIO_PCI=y/g' .config; \
  make modules_prepare"
