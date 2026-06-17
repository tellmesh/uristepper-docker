# UriImplementation: uristepper-python-mock

Implementacja `stepper://` dla Pythona. W Dockerze działa jako driver `mock`, ale ten sam kod ma szkic drivera `rpi-gpio-step-dir`.

```yaml markpact:implementation
apiVersion: urisys.io/v1
kind: UriImplementation
metadata:
  id: uristepper-python-mock
  version: 0.1.0
  language: python
  platform: linux-docker
implements:
  contract: uristepper.contract
  version: ^1.0.0
runtime:
  type: python-http
  endpoint: http://localhost:8791/uri/call
capabilities:
  - contract_query: stepper.status
    handler: python://uristepper.handlers:status
  - contract_command: stepper.enable
    handler: python://uristepper.handlers:enable
  - contract_command: stepper.disable
    handler: python://uristepper.handlers:disable
  - contract_command: stepper.stop
    handler: python://uristepper.handlers:stop
  - contract_command: stepper.move_relative
    handler: python://uristepper.handlers:move_relative
  - contract_command: stepper.move_absolute
    handler: python://uristepper.handlers:move_absolute
  - contract_command: stepper.home
    handler: python://uristepper.handlers:home
requires_device_config:
  axes:
    "{axis}":
      driver: string
      step_pin: integer
      dir_pin: integer
      enable_pin: integer
      enable_active_low: boolean
policy:
  require_approval_for: [command]
```
