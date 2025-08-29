# Makefile for service-slurm

# Variables
IMAGE_NAME = slurm-docker-cluster
IMAGE_TAG ?= 21.08

.PHONY: build
build:
	@echo "Building $(IMAGE_NAME):$(IMAGE_TAG)"
	@docker build -t $(IMAGE_NAME):$(IMAGE_TAG) . --no-cache

.PHONY: start
start:
	@docker compose up -d

.PHONY: stop
stop:
	@docker compose down

# Mode switching targets
.PHONY: start-rest
start-rest:
	@echo "Starting service-slurm in REST mode..."
	@./bin/switch-slurm-mode.sh rest

.PHONY: start-cli
start-cli:
	@echo "Starting service-slurm in CLI mode..."
	@./bin/switch-slurm-mode.sh cli

.PHONY: test-modes
test-modes:
	@echo "Testing both REST and CLI modes..."
	@./bin/test-slurm-modes.sh

# Helper targets
.PHONY: ssh
ssh:
	@SSH_PORT=$$(grep -oP 'SSH_PORT=\\K\\d+' .env || echo 2222); \
	echo "Connecting to service-slurm via SSH on port $$SSH_PORT..."; \
	ssh -o StrictHostKeyChecking=no -p $$SSH_PORT root@localhost

.PHONY: logs
logs:
	@docker compose logs -f

.PHONY: help
help:
	@echo "service-slurm Makefile targets:"
	@echo "  build        - Build the service-slurm Docker image"
	@echo "  start        - Start the service-slurm containers"
	@echo "  stop         - Stop the service-slurm containers"
	@echo "  start-rest   - Start service-slurm in REST mode"
	@echo "  start-cli    - Start service-slurm in CLI mode"
	@echo "  test-modes   - Test both REST and CLI modes"
	@echo "  ssh          - Connect to service-slurm via SSH (CLI mode)"
	@echo "  logs         - View container logs"
	@echo "  help         - Show this help message"
