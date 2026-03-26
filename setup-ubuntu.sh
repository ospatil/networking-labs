#!/bin/bash
# ============================================================
# Ubuntu Setup for Containerlab
# Run this script on any Ubuntu 24.04 LTS machine:
#   - Multipass VM, EC2 instance, Proxmox VM, bare metal
# ============================================================

set -e

echo "==> Installing Docker..."
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

# Add current user to docker group (skip if running as root with no regular user)
if [ -n "$SUDO_USER" ]; then
  usermod -aG docker "$SUDO_USER"
fi

echo "==> Installing Containerlab..."
curl -sL https://containerlab.dev/setup | sudo bash -s -- all

echo "==> Installing network tools..."
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

echo "==> Pulling container images..."
docker pull frrouting/frr:latest
docker pull ghcr.io/hellt/network-multitool
docker pull alpine:latest

echo ""
echo "============================================"
echo "  Setup complete!"
echo "============================================"
echo ""
echo "Clone or copy the lab files, then:"
echo "  cd networking-labs/phase1"
echo "  sudo containerlab deploy -t lab1.1-first-topology.clab.yml"
