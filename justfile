set shell := ["bash", "-euo", "pipefail", "-c"]
set dotenv-load
set positional-arguments

default:
    @just --list

[group('dev')]
lint:
    uv run ruff check .
    uv run ruff format --check .

[group('dev')]
fmt:
    uv run ruff format .
    uv run ruff check --fix .

[group('dev')]
test:
    uv run pytest
