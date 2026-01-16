#################################################################################
# GLOBALS                                                                       #
#################################################################################

PROJECT_NAME = wikimedia-opensearch-streams
PYTHON_VERSION = 3.12
PYTHON_INTERPRETER = python

#################################################################################
# COMMANDS                                                                      #
#################################################################################

## Install Python dependencies (Production)
.PHONY: requirements
requirements:
	$(PYTHON_INTERPRETER) -m pip install .

## Install Development dependencies
.PHONY: dev-requirements
dev-requirements:
	$(PYTHON_INTERPRETER) -m pip install -e .[dev]
	pre-commit install

## Delete all compiled Python files
.PHONY: clean
clean:
	find . -type f -name "*.py[co]" -delete
	find . -type d -name "__pycache__" -delete
	rm -rf .pytest_cache .ruff_cache

## Lint and format source code
.PHONY: lint
lint:
	ruff check --fix
	ruff format

## Run unit tests
.PHONY: test
test:
	$(PYTHON_INTERPRETER) -m pytest tests/unit

#################################################################
# INFRASTRUCTURE & EXECUTION
################################################################

## Start local Kafka, Schema Registry, and OpenSearch
.PHONY: infra-up
infra-up:
	docker-compose up -d kafka schema-registry opensearch grafana prometheus

## Shutdown all infrastructure
.PHONY: infra-down
infra-down:
	docker-compose down

## Phase 1: Run Wikimedia Producer
.PHONY: run-producer
run-producer:
	$(PYTHON_INTERPRETER) src/producer/producer.py

## Phase 2: Run Stream Processor
.PHONY: run-stream
run-stream:
	$(PYTHON_INTERPRETER) src/stream/processor.py

## Phase 3: Run OpenSearch Sink
.PHONY: run-sink
run-sink:
	$(PYTHON_INTERPRETER) src/sink/sink.py

#################################################################
# TERRAFORM (IaC)
################################################################

## Initialize Terraform
.PHONY: tf-init
tf-init:
	cd terraform && terraform init

## Apply Terraform changes (Creates Topics/Schemas)
.PHONY: tf-apply
tf-apply:
	cd terraform && terraform apply -auto-approve

#################################################################
# SETUP COMMANDS
################################################################

## One-shot setup: environment, deps, and infra
.PHONY: setup
setup: dev-requirements infra-up
	@echo "Infrastructure is starting. Run 'make tf-apply' once Kafka is healthy."

.DEFAULT_GOAL := help

# Self-documenting help script
define PRINT_HELP_PYSCRIPT
import re, sys; \
lines = '\n'.join([line for line in sys.stdin]); \
matches = re.findall(r'\n## (.*)\n([a-zA-Z_-]+):', lines); \
print('Available rules:\n'); \
print('\n'.join(['{:25}{}'.format(*reversed(match)) for match in matches]))
endef
export PRINT_HELP_PYSCRIPT

help:
	@$(PYTHON_INTERPRETER) -c "${PRINT_HELP_PYSCRIPT}" < $(MAKEFILE_LIST)