# ESP32-P4 implementation notes

Pythonowy `uristepper` dla RPi nie jest przenoszony na ESP32-P4. Przenoszony jest kontrakt:

```text
stepper://machine-01/axis/x/command/move-relative
```

Firmware ESP32-P4 powinien wystawić prosty endpoint:

```text
POST /uri/call
```

Payload:

```json
{
  "uri": "stepper://machine-01/axis/x/command/move-relative",
  "payload": {"steps": 200, "direction": "cw", "speed_sps": 500},
  "context": {"approved": true}
}
```

W firmware:

```text
uri_router.c
  -> match stepper://{device}/axis/{axis}/command/move-relative
  -> handle_stepper_move_relative
  -> RMT generates STEP pulses
  -> GPIO controls DIR and ENABLE
```

Device profile dla ESP32 powinien mieć pola typu:

```json
{
  "axes": {
    "x": {
      "driver": "esp32p4-rmt-step-dir",
      "step_gpio": 4,
      "dir_gpio": 5,
      "enable_gpio": 6,
      "rmt_channel": 0
    }
  }
}
```
