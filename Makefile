# dbt + uv + SQLFluff + Ruff — run from repo root.
# Requires: uv (https://docs.astral.sh/uv/). Optional: .env for Snowflake / dbt templater.

SHELL := /bin/bash

PROJECT_DIR ?= .
PROFILES_DIR ?= .
SQLFLUFF_PATHS := models macros analyses snapshots tests seeds

.PHONY: help sync install lint fix fmt dbt-deps dbt-parse dbt-run dbt-build dbt-test dbt-clean pre-commit

help:
	@echo "Targets:"
	@echo "  make sync          uv sync --frozen --group dev"
	@echo "  make install       same as sync"
	@echo "  make lint          ruff + sqlfluff lint ($(SQLFLUFF_PATHS))"
	@echo "  make fix           sqlfluff fix (same paths; needs .env for dbt templater)"
	@echo "  make fmt           ruff format ."
	@echo "  make dbt-deps      dbt deps (loads .env if present)"
	@echo "  make dbt-parse     dbt parse"
	@echo "  make dbt-run       dbt run"
	@echo "  make dbt-build     dbt build"
	@echo "  make dbt-test      dbt test"
	@echo "  make dbt-clean     dbt clean"
	@echo "  make pre-commit    pre-commit run --all-files"

install: sync

sync:
	uv sync --frozen --group dev

lint:
	uv run ruff check .
	uv run ruff format --check .
	bash scripts/sqlfluff-lint.sh $(SQLFLUFF_PATHS)

fix:
	bash scripts/sqlfluff-fix.sh $(SQLFLUFF_PATHS)

fmt:
	uv run ruff format .

dbt-deps:
	@cd "$(CURDIR)" && if [[ -f .env ]]; then set -a && source .env && set +a; fi && \
		uv run dbt deps --project-dir $(PROJECT_DIR) --profiles-dir $(PROFILES_DIR)

dbt-parse:
	@cd "$(CURDIR)" && if [[ -f .env ]]; then set -a && source .env && set +a; fi && \
		uv run dbt parse --project-dir $(PROJECT_DIR) --profiles-dir $(PROFILES_DIR)

dbt-run:
	@cd "$(CURDIR)" && if [[ -f .env ]]; then set -a && source .env && set +a; fi && \
		uv run dbt run --project-dir $(PROJECT_DIR) --profiles-dir $(PROFILES_DIR)

dbt-build:
	@cd "$(CURDIR)" && if [[ -f .env ]]; then set -a && source .env && set +a; fi && \
		uv run dbt build --project-dir $(PROJECT_DIR) --profiles-dir $(PROFILES_DIR)

dbt-test:
	@cd "$(CURDIR)" && if [[ -f .env ]]; then set -a && source .env && set +a; fi && \
		uv run dbt test --project-dir $(PROJECT_DIR) --profiles-dir $(PROFILES_DIR)

dbt-clean:
	@cd "$(CURDIR)" && if [[ -f .env ]]; then set -a && source .env && set +a; fi && \
		uv run dbt clean --project-dir $(PROJECT_DIR) --profiles-dir $(PROFILES_DIR)

pre-commit:
	uv run pre-commit run --all-files
