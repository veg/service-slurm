#!/bin/bash
# Script to test both REST and CLI modes for service-slurm

echo "===== Testing REST Mode ====="
./bin/switch-slurm-mode.sh rest
echo "Waiting for REST API to become available..."
sleep 10

# Test REST mode
echo "Testing REST API..."
curl -s http://localhost:9200/slurm/v0.0.36/ping
echo ""

echo "===== Testing CLI Mode ====="
./bin/switch-slurm-mode.sh cli
echo "Waiting for SSH to become available..."
sleep 10

# Test CLI mode
echo "Testing SSH connection..."
ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -p $(grep -oP 'SSH_PORT=\K\d+' .env || echo 2222) root@localhost "sinfo" || echo "SSH connection failed. Make sure the password is 'root'."

echo "===== Test Complete ====="
echo "Both modes have been tested. Check the output above for any errors."
