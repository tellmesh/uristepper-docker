#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
URISYS_ROOT="$(cd "$ROOT/.." && pwd)"
export PYTHONPATH="$URISYS_ROOT/packages/python:$ROOT/packages/python"
export URISYS_DEVICE_PROFILE="$ROOT/config/device-profile.json"
export URISYS_EVENTS_PATH="$ROOT/data/events.jsonl"
export URISYS_STATE_PATH="$ROOT/data/stepper_state.json"
python -m unittest discover -s "$ROOT/tests" -p 'test_*.py'
python -m uristepperedge --device-config "$ROOT/config/device-profile.json" --events "$ROOT/data/events.jsonl" flow "$ROOT/flows/move-test.uri.flow.yaml" --approve --dry-run
