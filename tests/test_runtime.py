from __future__ import annotations

import json
import os
import tempfile
import unittest
from pathlib import Path

from uristepperedge.runtime import build_runtime


class RuntimeTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        os.environ["URISYS_STATE_PATH"] = str(Path(self.tmp.name) / "state.json")
        self.events = str(Path(self.tmp.name) / "events.jsonl")
        self.profile = str(Path(__file__).resolve().parents[1] / "config" / "device-profile.json")
        self.rt = build_runtime(self.profile, self.events)

    def test_status(self):
        r = self.rt.call("stepper://machine-01/axis/x/query/status")
        self.assertTrue(r["ok"])
        self.assertEqual(r["result"]["axis"], "x")

    def test_policy_requires_approval(self):
        r = self.rt.call("stepper://machine-01/axis/x/command/enable")
        self.assertFalse(r["ok"])
        self.assertEqual(r["type"], "policy_denied")

    def test_move_relative(self):
        r = self.rt.call(
            "stepper://machine-01/axis/x/command/move-relative",
            {"steps": 100, "direction": "cw", "speed_sps": 250},
            {"approved": True},
        )
        self.assertTrue(r["ok"])
        s = self.rt.call("stepper://machine-01/axis/x/query/status")
        self.assertEqual(s["result"]["position_steps"], 100)

    def test_safety_limit(self):
        r = self.rt.call(
            "stepper://machine-01/axis/x/command/move-relative",
            {"steps": 1000000, "direction": "cw", "speed_sps": 250},
            {"approved": True},
        )
        self.assertFalse(r["ok"])
        self.assertIn("safety", r["error"])


if __name__ == "__main__":
    unittest.main()
