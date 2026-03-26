#!/bin/bash
# ============================================================
# Multipass VM Setup for Containerlab on macOS
# Run this script on your Mac to create and configure the VM
# ============================================================

set -e

VM_NAME="clab"
VM_CPUS=4
VM_MEMORY=8G
VM_DISK=40G
# UBUNTU_VERSION="22.04"

echo "==> Creating Multipass VM: $VM_NAME"
# multipass launch $UBUNTU_VERSION \
multipass launch \
  --name $VM_NAME \
  --cpus $VM_CPUS \
  --memory $VM_MEMORY \
  --disk $VM_DISK

echo "==> Installing Docker inside VM..."
multipass exec $VM_NAME -- bash -c '
  apt-get update -q
  apt-get install -y -q ca-certificates curl gnupg lsb-release
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    > /etc/apt/sources.list.d/docker.list
  apt-get update -q
  apt-get install -y -q docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  usermod -aG docker ubuntu
'

echo "==> Installing Containerlab inside VM..."
multipass exec $VM_NAME -- bash -c '
  curl -sL https://containerlab.dev/setup | sudo bash -s -- all
'

echo "==> Installing useful network tools..."
multipass exec $VM_NAME -- bash -c '
  apt-get install -y -q \
    tcpdump \
    wireshark-common \
    tshark \
    net-tools \
    iproute2 \
    bridge-utils \
    iputils-ping \
    traceroute \
    nmap \
    iperf3 \
    jq \
    tree \
    vim \
    tmux
'

echo "==> Pulling required container images..."
multipass exec $VM_NAME -- bash -c '
  docker pull frrouting/frr:latest
  docker pull ghcr.io/hellt/network-multitool
  docker pull alpine:latest
'

echo ""
echo "============================================"
echo "  Setup complete!"
echo "============================================"
echo ""
echo "To access your VM:"
echo "  multipass shell $VM_NAME"
echo ""
echo "To copy lab files into the VM:"
echo "  multipass transfer -r ./networking-labs $VM_NAME:/home/ubuntu/"
echo ""
echo "VM IP address:"
multipass info $VM_NAME | grep IPv4
