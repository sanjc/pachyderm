#!/bin/bash

set -ex

echo 'DOCKER_OPTS="-H unix:///var/run/docker.sock -s devicemapper"' | sudo tee /etc/default/docker > /dev/null

# Install deps
sudo apt-get update -y
sudo apt-get install -y -qq \
  jq \
  silversearcher-ag \
  python3 \
  python3-pip \
  python3-setuptools \
  pkg-config \
  fuse

# Install fuse
sudo modprobe fuse
sudo chmod 666 /dev/fuse
sudo cp etc/build/fuse.conf /etc/fuse.conf
sudo chown root:root /etc/fuse.conf

# Install aws CLI (for TLS test)
pip3 install --upgrade --user pip
pip3 install --upgrade --user wheel
pip3 install --upgrade --user awscli

# Install kubectl
# To get the latest kubectl version:
# curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt
if [ ! -f ~/cached-deps/kubectl ] ; then
    KUBECTL_VERSION=v1.13.0
    curl -L -o kubectl https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
        chmod +x ./kubectl && \
        mv ./kubectl ~/cached-deps/kubectl
fi

if [ ! -f ~/cached-deps/kind ] ; then
    curl -Lo kind https://github.com/kubernetes-sigs/kind/releases/download/v0.6.1/kind-linux-amd64 && \
    chmod +x kind && \
    mv ./kind ~/cached-deps/kind
fi

# Install vault
if [ ! -f ~/cached-deps/vault ] ; then
    curl -Lo vault.zip https://releases.hashicorp.com/vault/1.2.3/vault_1.2.3_linux_amd64.zip && \
        unzip vault.zip && \
        mv ./vault ~/cached-deps/vault
fi

# Install etcdctl
# To get the latest etcd version:
# curl -Ls https://api.github.com/repos/etcd-io/etcd/releases | jq -r .[].tag_name
if [ ! -f ~/cached-deps/etcdctl ] ; then
    ETCD_VERSION=v3.3.12
    curl -L https://storage.googleapis.com/etcd/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz \
        | tar xzf - --strip-components=1 && \
        mv ./etcdctl ~/cached-deps/etcdctl
fi

# Install kubeval
if [ ! -f ~/cached-deps/kubeval ]; then
  KUBEVAL_VERSION=0.14.0
  curl -L https://github.com/instrumenta/kubeval/releases/download/${KUBEVAL_VERSION}/kubeval-linux-amd64.tar.gz \
      | tar xzf - kubeval && \
      mv ./kubeval ~/cached-deps/kubeval
fi
