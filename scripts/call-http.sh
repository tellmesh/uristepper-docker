#!/usr/bin/env bash
set -euo pipefail
BASE="${URISTEPPER_BASE_URL:-http://127.0.0.1:8791}"
curl -sS -X POST "$BASE/uri/call" \
  -H 'Content-Type: application/json' \
  -d '{
    "uri": "stepper://machine-01/axis/x/command/move-relative",
    "payload": {"steps": 200, "direction": "cw", "speed_sps": 250},
    "context": {"approved": true}
  }' | python -m json.tool
