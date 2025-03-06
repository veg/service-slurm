# Slurm REST Docker Cluster with HyPhy

The idea currently is that this is useful to develop against. If we want to put this image into production, it probably means investigating Docker Swarm or something. But either way, this repo should prove very useful for anyone attempting local development of the backend of datamonkey3.

# Table of contents

- [Slurm REST Docker Cluster](#slurm-rest-docker-cluster)
- [Table of contents](#table-of-contents)
- [Introduction](#introduction)
- [REST API](#rest-api)
- [JWT Authentication](#jwt-authentication)
- [Using Custom JWT Keys](#using-custom-jwt-keys)

# Introduction

[This is a fork of the SLURM REST Docker repo here.](https://github.com/JBris/slurm-rest-api-docker)

[Which is in turn a fork of the SLURM Docker repo here.](https://github.com/giovtorres/slurm-docker-cluster)

[The principal difference is that the dependencies required for HyPhy have been included in the image build.](https://github.com/veg/hyphy)

# REST API

1. Run `docker compose up -d` to launch a local SLURM cluster.
2. Within the *c2* node, set the JSON web token: `export $(docker compose exec c2 scontrol token)`
3. Test that you can access the SLURM API documentation: `curl -k -vvvv -H X-SLURM-USER-TOKEN:${SLURM_JWT} -H X-SLURM-USER-NAME:root -X GET 'http://localhost:9200/openapi/v3' > docs.json`
4. Submit a SLURM job: `curl -X POST "http://localhost:9200/slurm/v0.0.37/job/submit" -H "X-SLURM-USER-NAME:root" -H "X-SLURM-USER-TOKEN:${SLURM_JWT}" -H "Content-Type: application/json" -d @rest_api_test.json`
5. Check that the SLURM job completed successfully: `docker compose exec c1 cat /root/test.out`
6. Submit a job to test HyPhy installation: `curl -X POST "http://localhost:9200/slurm/v0.0.37/job/submit" -H "X-SLURM-USER-NAME:root" -H "X-SLURM-USER-TOKEN:${SLURM_JWT}" -H "Content-Type: application/json" -d @hyphy_test.json`
7. Check the HyPhy version reported successfully: `docker compose exec c1 cat /root/hyphy_test.out`

# JWT Authentication

The Slurm REST API uses JWT (JSON Web Token) authentication. By default, the container generates a random JWT key during startup. This key is used to sign and verify JWTs for authentication.

# Using Custom JWT Keys

For production environments or when you need consistent authentication across container restarts, you can provide your own JWT key.

## Generating a JWT Key

We provide a helper script to generate a compliant JWT key:

```bash
# Generate a key with default settings
./generate-jwt-key.sh

# Generate a key with custom output location
./generate-jwt-key.sh --dir /path/to/keys --output my_jwt_key
```

The script will generate a 256-bit key. Be sure to set the necessary environment variables. See below.

## Environment Variables

- `JWT_KEY_PATH`: Path inside the container where the JWT key should be stored (default: `/var/spool/slurm/statesave/jwt_hs256.key`)
- `EXTERNAL_JWT_KEY_PATH`: Path to an external JWT key that will be copied to `JWT_KEY_PATH`
- `JWT_KEY_VOLUME`: Volume mount for the external JWT key. Format: /path/to/local/key:[EXTERNAL_JWT_KEY_PATH]:ro

A sample `.env.example` file is provided as a template for your environment variables.
