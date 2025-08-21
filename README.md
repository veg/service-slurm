# Slurm REST Docker Cluster with HyPhy

The idea currently is that this is useful to develop against. If we want to put this image into production, it probably means investigating Docker Swarm or something. But either way, this repo should prove very useful for anyone attempting local development of the backend of datamonkey3.

# Table of contents

- [Slurm REST Docker Cluster](#slurm-rest-docker-cluster)
- [Table of contents](#table-of-contents)
- [Introduction](#introduction)
- [Interface Modes](#interface-modes)
  - [REST API Mode](#rest-api-mode)
  - [CLI Mode](#cli-mode)
- [Makefile Usage](#makefile-usage)
- [JWT Authentication](#jwt-authentication)
- [Using Custom JWT Keys](#using-custom-jwt-keys)

# Introduction

[This is a fork of the SLURM REST Docker repo here.](https://github.com/JBris/slurm-rest-api-docker)

[Which is in turn a fork of the SLURM Docker repo here.](https://github.com/giovtorres/slurm-docker-cluster)

[The principal difference is that the dependencies required for HyPhy have been included in the image build.](https://github.com/veg/hyphy)

# Interface Modes

This Slurm Docker cluster supports two interface modes:

- **REST API Mode**: Interact with Slurm through its REST API (default)
- **CLI Mode**: Interact with Slurm through traditional command-line interface

The mode is controlled by the `SLURM_INTERFACE` environment variable in your `.env` file or when running docker-compose.

## REST API Mode

1. Set the mode in your `.env` file: `SLURM_INTERFACE=rest` (this is the default if not specified)
2. Run `docker compose up -d` to launch a local SLURM cluster.
3. Within the *c2* node, set the JSON web token: `export $(docker compose exec c2 scontrol token)`
4. Test that you can access the SLURM API documentation: `curl -k -vvvv -H X-SLURM-USER-TOKEN:${SLURM_JWT} -H X-SLURM-USER-NAME:root -X GET 'http://localhost:9200/openapi/v3' > docs.json`
5. Submit a SLURM job: `curl -X POST "http://localhost:9200/slurm/v0.0.37/job/submit" -H "X-SLURM-USER-NAME:root" -H "X-SLURM-USER-TOKEN:${SLURM_JWT}" -H "Content-Type: application/json" -d @rest_api_test.json`
6. Check that the SLURM job completed successfully: `docker compose exec c1 cat /root/test.out`
7. Submit a job to test HyPhy installation: `curl -X POST "http://localhost:9200/slurm/v0.0.37/job/submit" -H "X-SLURM-USER-NAME:root" -H "X-SLURM-USER-TOKEN:${SLURM_JWT}" -H "Content-Type: application/json" -d @hyphy_test.json`
8. Check the HyPhy version reported successfully: `docker compose exec c1 cat /root/hyphy_test.out`

## CLI Mode

1. Set the mode in your `.env` file: `SLURM_INTERFACE=cli`
2. Optionally configure the SSH port in your `.env` file: `SSH_PORT=2222` (default if not specified)
3. Run `docker compose up -d` to launch a local SLURM cluster.
4. SSH into the c2 node: `ssh -p 2222 root@localhost` (default password is "root")
5. Use standard Slurm commands directly:
   ```bash
   # Check cluster status
   sinfo
   
   # Submit a job
   sbatch -N1 --wrap="echo Hello World > /tmp/hello.out"
   
   # Check job status
   squeue
   
   # View job output
   cat /tmp/hello.out
   ```
6. You can also run HyPhy directly: `hyphy --version`

# Makefile Usage

This repository includes a Makefile to simplify common operations. The following targets are available:

```bash
# Build the Docker image
make build

# Start the containers (uses the mode specified in .env, defaults to REST mode)
make start

# Stop the containers
make stop

# Start in REST mode (sets SLURM_INTERFACE=rest in .env)
make start-rest

# Start in CLI mode (sets SLURM_INTERFACE=cli in .env)
make start-cli

# Test both REST and CLI modes sequentially
make test-modes

# Connect to the c2 container via SSH (for CLI mode)
make ssh

# View container logs
make logs

# Show help message
make help
```

The `make start` command will use whatever mode is currently set in your `.env` file (defaults to REST mode if not specified). For explicit mode selection, use `make start-rest` or `make start-cli` instead.

# JWT Authentication

The Slurm REST API uses JWT (JSON Web Token) authentication. By default, the container generates a random JWT key during startup. This key is used to sign and verify JWTs for authentication.

# Using Custom JWT Keys

For production environments or when you need consistent authentication across container restarts, you can provide your own JWT key.

## Generating a JWT Key

We provide a helper script to generate a compliant JWT key:

```bash
# Generate a key with default settings
./bin/generate-jwt-key.sh

# Generate a key with custom output location
./bin/generate-jwt-key.sh --dir /path/to/keys --output my_jwt_key
```

The script will generate a 256-bit key. Be sure to set the necessary environment variables. See below.

## Environment Variables

### JWT Authentication
- `JWT_KEY_PATH`: Path inside the container where the JWT key should be stored (default: `/var/spool/slurm/statesave/jwt_hs256.key`)
- `EXTERNAL_JWT_KEY_PATH`: Path to an external JWT key that will be copied to `JWT_KEY_PATH`
- `JWT_KEY_VOLUME`: Volume mount for the external JWT key. Format: /path/to/local/key:[EXTERNAL_JWT_KEY_PATH]:ro

### Interface Mode
- `SLURM_INTERFACE`: Set to `rest` for REST API mode or `cli` for command-line interface mode (default: `rest`)
- `SSH_PORT`: Host port to map to container's SSH port when using CLI mode (default: `2222`)

A sample `.env.example` file is provided as a template for your environment variables.
