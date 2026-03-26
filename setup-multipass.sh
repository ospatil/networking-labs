#!/bin/bash
# ============================================================
# Multipass VM Setup for Containerlab (macOS)
# Run this script on your Mac to create and configure the VM.
# Uses the latest Ubuntu LTS (currently 24.04 Noble Numbat).
# ============================================================

set -e

VM_NAME="clab"
VM_CPUS=4
VM_MEMORY=8G
VM_DISK=40G

echo "==> Creating Multipass VM: $VM_NAME (latest Ubuntu LTS)"
multipass launch \
  --name $VM_NAME \
  --cpus $VM_CPUS \
  --memory $VM_MEMORY \
  --disk $VM_DISK

echo "==> Transferring setup script into VM..."
multipass transfer setup-ubuntu.sh $VM_NAME:/home/ubuntu/setup-ubuntu.sh

echo "==> Running setup inside VM..."
multipass exec $VM_NAME -- sudo bash /home/ubuntu/setup-ubuntu.sh

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
