#!/bin/bash
# Script to switch between REST and CLI modes for service-slurm

# Default to REST mode if no argument is provided
MODE=${1:-rest}

# Validate mode argument
if [ "$MODE" != "rest" ] && [ "$MODE" != "cli" ]; then
    echo "Error: Invalid mode. Use 'rest' or 'cli'."
    echo "Usage: $0 [rest|cli]"
    exit 1
fi

# Check if .env exists, if not, create it from .env.example
if [ ! -f .env ]; then
    echo "Creating .env from .env.example..."
    cp .env.example .env
fi

# Stop any running containers
echo "Stopping any running containers..."
docker compose down 2>/dev/null

# Update SLURM_INTERFACE in .env without overwriting the file
echo "Setting SLURM_INTERFACE=$MODE in .env..."
sed -i "s/^SLURM_INTERFACE=.*/SLURM_INTERFACE=$MODE/" .env

# Start containers using docker-compose
echo "Starting containers in $MODE mode..."
docker compose up -d

if [ "$MODE" = "rest" ]; then
    echo "REST mode activated. Service is accessible at http://localhost:9200"
    echo "Note: You may need to wait a moment for the REST API to become available."
else
    echo "CLI mode activated. SSH access is available on port $(grep -oP 'SSH_PORT=\K\d+' .env || echo 2222)"
    echo "You can connect using: ssh root@localhost -p $(grep -oP 'SSH_PORT=\K\d+' .env || echo 2222)"
    echo "Default password: root"
fi

echo "Done!"
