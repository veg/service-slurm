#!/bin/bash
# Script to set up SSH access for CLI mode

# Set a default password for root user
echo "root:root" | chpasswd

# Generate SSH host keys if they don't exist
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    ssh-keygen -A
fi

# Start the SSH server
/usr/sbin/sshd

echo "SSH server started. You can connect using:"
echo "ssh -p \${SSH_PORT:-2222} root@localhost"
echo "Default password: root"
