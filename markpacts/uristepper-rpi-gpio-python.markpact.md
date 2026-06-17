# UriImplementation: uristepper-rpi-gpio-python

Implementacja `stepper://` dla Raspberry Pi przez GPIO STEP/DIR. Ten Markpact jest kontraktem instalacyjnym; realne uruchomienie wymaga Raspberry Pi OS, GPIO i zależności typu `gpiozero`/`lgpio`.

```yaml markpact:implementation
apiVersion: urisys.io/v1
kind: UriImplementation
metadata:
  id: uristepper-rpi-gpio-python
  version: 0.1.0
  language: python
  platform: raspberry-pi
implements:
  contract: uristepper.contract
  version: ^1.0.0
runtime:
  type: python-http
  service_name: urisys-edge-stepper
capabilities:
  - contract_command: stepper.move_relative
    handler: python://uristepper.handlers:move_relative
  - contract_query: stepper.status
    handler: python://uristepper.handlers:status
dependencies:
  python:
    - gpiozero
  system:
    - python3
    - python3-venv
requires_device_config:
  axes:
    "{axis}":
      driver: rpi-gpio-step-dir
      step_pin: integer
      dir_pin: integer
      enable_pin: integer
      enable_active_low: boolean
install:
  ssh:
    summary: Install runtime on Raspberry Pi and create systemd service.
    commands:
      - python3 -m venv /opt/urisys-edge/.venv
      - /opt/urisys-edge/.venv/bin/pip install gpiozero lgpio
      - install -d /etc/urisys /var/lib/urisys
      - systemctl enable --now urisys-edge-stepper.service
```
