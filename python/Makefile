BUILD_TOOL = $(shell (test -s poetry.lock && echo "poetry") || (test -s Pipfile.lock && echo "pipenv"))

ifeq ($(BUILD_TOOL),)
$(error Unsupported build tool, project must use Poetry or Pipenv for Bonjour Software Limited build-tools to work)
endif

PYTHON_VERSION ?= $(shell head -1 .python-version)
PROJECT_NAME ?= $(shell basename $$(pwd))
BUILD_TOOL_TAG ?= bonjoursoftware/$(PROJECT_NAME):$(BUILD_TOOL)
LOCAL_TAG ?= bonjoursoftware/$(PROJECT_NAME):local
SRC_DIR ?= $(PROJECT_NAME)

RUN = docker run --rm $(BUILD_TOOL_TAG)

.PHONY: help
help:
	@echo "Bonjour Software Limited build-tools for Python - https://github.com/bonjoursoftware/build-tools/"
	@echo ""
	@echo "Make targets:"
	@echo "- all-checks: alias for 'code-check fmt-check md-check test'"
	@echo "- code-check: check code style with flake8 and static typing with mypy"
	@echo "- debug     : print Makefile config"
	@echo "- fmt       : format code with black"
	@echo "- fmt-check : check code formatting with black"
	@echo "- help      : print this manual"
	@echo "- md-check  : check markdown formatting with remark"
	@echo "- package   : package the Python application in a container"
	@echo "- test      : run the test suite with pytest and check coverage with pytest-cov"

.PHONY: all-checks
all-checks: code-check fmt-check md-check test

.PHONY: build
build:
	@curl -fsL https://github.com/bonjoursoftware/build-tools/raw/main/python/$(BUILD_TOOL).Dockerfile | docker build \
		--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
		--tag $(BUILD_TOOL_TAG) \
		--target $(BUILD_TOOL) \
		-f- . > /dev/null

.PHONY: build-tool
build-tool:
	@echo "$(BUILD_TOOL)"

.PHONY: code-check
code-check: flake8 mypy

.PHONY: debug
debug:
	@echo "BUILD_TOOL=$(BUILD_TOOL)"
	@echo "PYTHON_VERSION=$(PYTHON_VERSION)"
	@echo "PROJECT_NAME=$(PROJECT_NAME)"
	@echo "BUILD_TOOL_TAG=$(BUILD_TOOL_TAG)"
	@echo "LOCAL_TAG=$(LOCAL_TAG)"
	@echo "SRC_DIR=$(SRC_DIR)"

.PHONY: flake8
flake8: build
	@$(RUN) flake8 --max-line-length 160 --exclude venv

.PHONY: fmt
fmt:
	@$(BUILD_TOOL) run black --line-length 160 .

.PHONY: fmt-check
fmt-check: build
	@$(RUN) black --line-length 160 --check . --exclude venv

.PHONY: md-check
md-check:
	@docker pull zemanlx/remark-lint:0.2.0 >/dev/null
	@curl -fsL https://github.com/bonjoursoftware/build-tools/raw/main/markdown/.remarkrc.yaml > .remarkrc.yaml
	@curl -fsL https://github.com/bonjoursoftware/build-tools/raw/main/markdown/.remarkignore > .remarkignore
	@docker run --rm -i -v $(PWD):/lint/input:ro zemanlx/remark-lint:0.2.0 --frail .

.PHONY: mypy
mypy: build
	@$(RUN) mypy --strict $(SRC_DIR) tests

.PHONY: package
package:
	@curl -fsL https://github.com/bonjoursoftware/build-tools/raw/main/python/$(BUILD_TOOL).Dockerfile | docker build \
		--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
		--build-arg PROJECT_NAME=$(PROJECT_NAME) \
		--tag $(LOCAL_TAG) \
		-f- . > /dev/null

.PHONY: test
test: build
	@$(RUN) pytest \
		-v \
		-p no:cacheprovider \
		--no-header \
		--cov=$(SRC_DIR) \
		--cov-fail-under=100 \
		--cov-report term-missing \
		--no-cov-on-fail
