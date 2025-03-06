#!/bin/bash
set -e

# Add debugging
echo "DEBUG: Starting JWT key setup"
echo "DEBUG: JWT_KEY_PATH = $JWT_KEY_PATH"
echo "DEBUG: EXTERNAL_JWT_KEY_PATH = $EXTERNAL_JWT_KEY_PATH"

# Create directory if it doesn't exist
mkdir -p "$(dirname "$JWT_KEY_PATH")"

# Check if we need to copy an external key or generate one
if [ -n "$EXTERNAL_JWT_KEY_PATH" ] && [ -f "$EXTERNAL_JWT_KEY_PATH" ]; then
    echo "Using external JWT key from $EXTERNAL_JWT_KEY_PATH"
    echo "DEBUG: External key exists, copying to $JWT_KEY_PATH"
    cp "$EXTERNAL_JWT_KEY_PATH" "$JWT_KEY_PATH"
    chown slurm:slurm "$JWT_KEY_PATH"
    chmod 0600 "$JWT_KEY_PATH"
    echo "DEBUG: Key copied and permissions set"
    ls -la "$JWT_KEY_PATH"
else
    echo "No external JWT key provided, generating a random key"
    echo "DEBUG: Generating random key at $JWT_KEY_PATH"
    # Generate a random key if no external key is provided
    dd if=/dev/random of="$JWT_KEY_PATH" bs=32 count=1 2>/dev/null
    chown slurm:slurm "$JWT_KEY_PATH"
    chmod 0600 "$JWT_KEY_PATH"
    echo "DEBUG: Random key generated and permissions set"
    ls -la "$JWT_KEY_PATH"
fi
