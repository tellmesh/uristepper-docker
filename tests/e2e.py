from __future__ import annotations

import json
import os
import sys
import urllib.request

BASE = os.environ.get("URISTEPPER_BASE_URL", "http://127.0.0.1:8791")


def post(path, data):
    body = json.dumps(data).encode("utf-8")
    req = urllib.request.Request(BASE + path, data=body, headers={"Content-Type": "application/json"}, method="POST")
    with urllib.request.urlopen(req, timeout=10) as r:
        return json.loads(r.read().decode("utf-8"))


def get(path):
    with urllib.request.urlopen(BASE + path, timeout=10) as r:
        return json.loads(r.read().decode("utf-8"))


def assert_ok(result, label):
    if not result.get("ok"):
        print(label, json.dumps(result, indent=2), file=sys.stderr)
        raise SystemExit(1)


def main():
    assert_ok(get("/health"), "health")
    assert_ok(get("/routes"), "routes")

    assert_ok(post("/uri/call", {"uri": "stepper://machine-01/axis/x/query/status"}), "status")

    denied = post("/uri/call", {
        "uri": "stepper://machine-01/axis/x/command/move-relative",
        "payload": {"steps": 10, "direction": "cw", "speed_sps": 100},
        "context": {}
    })
    if denied.get("ok"):
        print("expected policy_denied without approved", file=sys.stderr)
        raise SystemExit(1)

    assert_ok(post("/uri/call", {
        "uri": "stepper://machine-01/axis/x/command/enable",
        "context": {"approved": True}
    }), "enable")

    assert_ok(post("/uri/call", {
        "uri": "stepper://machine-01/axis/x/command/move-relative",
        "payload": {"steps": 200, "direction": "cw", "speed_sps": 250},
        "context": {"approved": True}
    }), "move")

    too_far = post("/uri/call", {
        "uri": "stepper://machine-01/axis/x/command/move-relative",
        "payload": {"steps": 999999, "direction": "cw", "speed_sps": 250},
        "context": {"approved": True}
    })
    if too_far.get("ok"):
        print("expected safety denial for large steps", file=sys.stderr)
        raise SystemExit(1)

    events = get("/events")
    assert_ok(events, "events")
    print(json.dumps({"ok": True, "message": "uristepper docker e2e passed", "event_count": len(events.get("events", []))}, indent=2))


if __name__ == "__main__":
    main()
