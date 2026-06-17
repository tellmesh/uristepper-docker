#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
docker compose build
docker compose --profile test up --abort-on-container-exit --exit-code-from e2e e2e
docker compose down -v
