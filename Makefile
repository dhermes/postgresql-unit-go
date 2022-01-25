# Copyright 2022 Danny Hermes
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

.PHONY: help
help:
	@echo 'Makefile for `postgresql-unit-go` project'
	@echo ''
	@echo 'Usage:'
	@echo '   make vet                          Run `go vet` over project source tree'
	@echo '   make staticcheck                  Run `staticcheck` over project source tree'
	@echo 'Development Database-specific Targets:'
	@echo '   make start-postgres               Starts a PostgreSQL database running in a Docker container and set up users'
	@echo '   make stop-postgres                Stops the PostgreSQL database running in a Docker container'
	@echo '   make restart-postgres             Stops the PostgreSQL database (if running) and starts a fresh Docker container'
	@echo '   make psql                         Connects to currently running PostgreSQL DB via `psql` as app user'
	@echo '   make pgcli                        Connects to currently running PostgreSQL DB via `pgcli` as app user'
	@echo '   make psql-admin                   Connects to currently running PostgreSQL DB via `psql` as admin user'
	@echo '   make pgcli-admin                  Connects to currently running PostgreSQL DB via `pgcli` as admin user'
	@echo '   make psql-superuser               Connects to currently running PostgreSQL DB via `psql` as superuser'
	@echo '   make pgcli-superuser              Connects to currently running PostgreSQL DB via `pgcli` as superuser'
	@echo '   make show-postgres-env            Display environment variables used when creating the development instance of the database'
	@echo ''

################################################################################
# Meta-variables
################################################################################
HERE := $(shell pwd)
PSQL_PRESENT := $(shell command -v psql 2> /dev/null)
PGCLI_PRESENT := $(shell command -v pgcli 2> /dev/null)

################################################################################
# Development Database-specific variables
################################################################################
DB_HOST ?= 127.0.0.1
DB_NETWORK_NAME ?= dev-network-unit

DB_PORT ?= 20699
DB_CONTAINER_NAME ?= dev-postgres-unit

DB_SUPERUSER_NAME ?= superuser_db
DB_SUPERUSER_USER ?= superuser
DB_SUPERUSER_PASSWORD ?= testpassword_superuser

DB_NAME ?= unit
DB_SCHEMA ?= unit
DB_ADMIN_USER ?= unit_admin
DB_ADMIN_PASSWORD ?= testpassword_admin
DB_APP_USER ?= unit_app
DB_APP_PASSWORD ?= testpassword_app

# NOTE: This assumes the `DB_*_{USER,PASSWORD}` values do not need to be URL encoded.
DB_APP_DSN ?= postgres://$(DB_APP_USER):$(DB_APP_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)
DB_ADMIN_DSN ?= postgres://$(DB_ADMIN_USER):$(DB_ADMIN_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)
DB_SUPERUSER_DSN ?= postgres://$(DB_SUPERUSER_USER):$(DB_SUPERUSER_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_SUPERUSER_NAME)

################################################################################
# Generic Targets
################################################################################

.PHONY: vet
vet:
	go vet ./...

.PHONY: staticcheck
staticcheck:
	go run ./vendor/honnef.co/go/tools/cmd/staticcheck/ ./...

################################################################################
# Development Database-specific Targets
################################################################################

.PHONY: _start-postgres-docker
_start-postgres-docker:
	exit 1

.PHONY: _postgres-migrations
_postgres-migrations:
	exit 1

.PHONY: start-postgres
start-postgres: _start-postgres-docker _postgres-migrations

.PHONY: stop-postgres
stop-postgres:
	exit 1

.PHONY: restart-postgres
restart-postgres: stop-postgres start-postgres

.PHONY: psql
psql: _require-psql
	@echo "Running psql against port $(DB_PORT)"
	psql "$(DB_APP_DSN)"

.PHONY: pgcli
pgcli: _require-pgcli
	@echo "Running pgcli against port $(DB_PORT)"
	pgcli "$(DB_APP_DSN)"

.PHONY: psql-admin
psql-admin: _require-psql
	@echo "Running psql against port $(DB_PORT)"
	psql "$(DB_ADMIN_DSN)"

.PHONY: pgcli-admin
pgcli-admin: _require-pgcli
	@echo "Running pgcli against port $(DB_PORT)"
	pgcli "$(DB_ADMIN_DSN)"

.PHONY: psql-superuser
psql-superuser: _require-psql
	@echo "Running psql against port $(DB_PORT)"
	psql "$(DB_SUPERUSER_DSN)"

.PHONY: pgcli-superuser
pgcli-superuser: _require-pgcli
	@echo "Running pgcli against port $(DB_PORT)"
	pgcli "$(DB_SUPERUSER_DSN)"

.PHONY: show-postgres-env
show-postgres-env:
	@echo "    DB_HOST=$(DB_HOST)"
	@echo "    DB_PORT=$(DB_PORT)"
	@echo "    DB_NAME=$(DB_NAME)"
	@echo "    DB_USER=$(DB_APP_USER)"
	@echo "DB_PASSWORD=$(DB_APP_PASSWORD)"

################################################################################
# Internal / Doctor Targets
################################################################################

.PHONY: _require-psql
_require-psql:
ifndef PSQL_PRESENT
	$(error 'psql is not installed, it can be installed via "brew install postgresql" or "apt-get install postgresql".')
endif

.PHONY: _require-pgcli
_require-pgcli:
ifndef PGCLI_PRESENT
	$(error 'psql is not installed, it can be installed via "python -m pip install pgcli".')
endif
