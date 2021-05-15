BUILD_TOOL = $(shell (test -s poetry.lock && echo "poetry") || (test -s Pipfile.lock && echo "pipenv"))
PYTHON_VERSION ?= $(shell head -1 .python-version)
PROJECT_NAME ?= $(shell basename $$(pwd))
BUILD_TOOL_TAG ?= bonjoursoftware/$(PROJECT_NAME):$(BUILD_TOOL)
LOCAL_TAG ?= bonjoursoftware/$(PROJECT_NAME):local
SRC_DIR ?= $(PROJECT_NAME)

RUN = docker run --rm $(BUILD_TOOL_TAG)

ifeq ($(BUILD_TOOL),)
$(error Unsupported build tool, project must use Poetry or Pipenv for this to work)
endif

.PHONY: all
all: fmt-check test static-analysis md-check package

.PHONY: debug
debug:
	@echo "BUILD_TOOL=$(BUILD_TOOL)"
	@echo "PYTHON_VERSION=$(PYTHON_VERSION)"
	@echo "PROJECT_NAME=$(PROJECT_NAME)"
	@echo "BUILD_TOOL_TAG=$(BUILD_TOOL_TAG)"
	@echo "LOCAL_TAG=$(LOCAL_TAG)"
	@echo "SRC_DIR=$(SRC_DIR)"

.PHONY: docker-build
docker-build:
	@curl -fsL https://github.com/bonjoursoftware/build-tools/raw/main/python/$(BUILD_TOOL).Dockerfile | docker build \
		--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
		--tag $(BUILD_TOOL_TAG) \
		-f- . > /dev/null

.PHONY: fmt-check
fmt-check: docker-build
	@$(RUN) black --line-length 120 --check .

.PHONY: test
test: docker-build
	@$(RUN) pytest \
		-v \
		-p no:cacheprovider \
		--no-header \
		--cov=$(SRC_DIR) \
		--cov-fail-under=100 \
		--no-cov-on-fail

.PHONY: static-analysis
static-analysis: flake8 mypy

.PHONY: flake8
flake8: docker-build
	@$(RUN) flake8 --max-line-length 120

.PHONY: mypy
mypy: docker-build
	@$(RUN) mypy --strict ./**/*.py

.PHONY: fmt
fmt:
	@pipenv run black --line-length 120 .

.PHONY: md-check
md-check:
	@docker pull zemanlx/remark-lint:0.2.0 >/dev/null
	@curl -fsL https://github.com/bonjoursoftware/build-tools/raw/main/markdown/.remarkrc.yaml > .remarkrc.yaml
	@docker run --rm -i -v $(PWD):/lint/input:ro zemanlx/remark-lint:0.2.0 --frail .

.PHONY: package
package:
	@docker build \
		--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
		--tag $(LOCAL_TAG) \
		. > /dev/null
