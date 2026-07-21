.PHONY: help setup dev test lint clean docker-up docker-down docker-build

help:
	@echo "Koturna Makefile"
	@echo ""
	@echo "Usage:"
	@echo "  make setup         - Install deps, run migrations, seed, build assets"
	@echo "  make dev           - Start Phoenix server in dev mode"
	@echo "  make test          - Run test suite"
	@echo "  make lint          - Run linter (credo + format check)"
	@echo "  make clean         - Clean build artifacts"
	@echo "  make docker-build  - Build Docker image"
	@echo "  make docker-up     - Start Docker container"

setup:
	mix deps.get
	mix ecto.create
	mix ecto.migrate
	mix run priv/repo/seeds.exs
	mix assets.setup
	mix assets.build

dev:
	mix phx.server

test:
	mix test

lint:
	mix format --check-formatted
	mix credo --strict

clean:
	mix clean
	rm -rf _build
	rm -rf priv/static/assets

docker-build:
	docker-compose build

docker-up:
	docker-compose up -d

docker-down:
	docker-compose down
