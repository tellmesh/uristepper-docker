#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TELLMESH="$(cd "$ROOT/.." && pwd)"
export URISYS_DEVICE_PROFILE="$ROOT/config/device-profile.json"
export URISYS_EVENTS_PATH="$ROOT/data/events.jsonl"
export URISYS_STATE_PATH="$ROOT/data/stepper_state.json"
mkdir -p "$ROOT/data"
cd "$TELLMESH/uristepper-docker"
uv run pytest tests/test_runtime.py -q
uv run python -m uristepperedge \
  --device-config "$ROOT/config/device-profile.json" \
  --events "$ROOT/data/events.jsonl" \
  flow "$ROOT/flows/move-test.uri.flow.yaml" --approve --dry-run
