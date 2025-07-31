#!/bin/bash
set -e

# Add debugging
echo "DEBUG: Starting JWT key setup"
echo "DEBUG: JWT_KEY_PATH = $JWT_KEY_PATH"

# Create directory if it doesn't exist
mkdir -p "$(dirname "$JWT_KEY_PATH")"

# Check if the JWT key already exists at the specified path
if [ -f "$JWT_KEY_PATH" ]; then
    echo "JWT key already exists at $JWT_KEY_PATH"
    # Ensure proper permissions
    chown slurm:slurm "$JWT_KEY_PATH" 2>/dev/null || echo "Warning: Could not change ownership (likely mounted read-only)"
    chmod 0600 "$JWT_KEY_PATH" 2>/dev/null || echo "Warning: Could not change permissions (likely mounted read-only)"
    echo "DEBUG: Using existing key"
    ls -la "$JWT_KEY_PATH" 2>/dev/null || echo "Cannot list file details (likely due to permissions)"
else
    echo "No JWT key found, generating a random key"
    echo "DEBUG: Generating random key at $JWT_KEY_PATH"
    # Generate a random key
    dd if=/dev/random of="$JWT_KEY_PATH" bs=32 count=1 2>/dev/null
    chown slurm:slurm "$JWT_KEY_PATH"
    chmod 0600 "$JWT_KEY_PATH"
    echo "DEBUG: Random key generated and permissions set"
    ls -la "$JWT_KEY_PATH"
fi
