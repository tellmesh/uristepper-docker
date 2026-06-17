# Routing `stepper://`

Kolejność wykonania:

```text
HTTP POST /uri/call
  -> parse envelope JSON
  -> match stepper:// pattern
  -> policy: czy command ma approved=true
  -> device profile: axis config + safety
  -> handler
  -> driver: mock / rpi-gpio-step-dir / later esp32-rmt / usb-tic
  -> event JSONL
```

## Ten sam kontrakt, różne implementacje

```text
stepper://machine-01/axis/x/command/move-relative
```

Może być wykonany przez:

```text
Docker mock        -> uristepper-python-mock
RPi GPIO STEP/DIR  -> uristepper-rpi-gpio-python
ESP32-P4 RMT       -> uristepper-esp32p4-rmt-c
Pololu Tic USB     -> uristepper-pololu-tic-python
```

Aplikacja i flow nie muszą się zmieniać.

## Co jest prywatne

Nie publikuj publicznie konfiguracji realnej maszyny, jeśli zawiera hosty, porty, piny i limity produkcyjne.

Publiczne:

```text
contracts
implementations
README
tests mock
```

Prywatne:

```text
device-profile.json
routes.yaml
.env
secrets
```
