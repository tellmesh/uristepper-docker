# UriContract: uristepper

Publiczny kontrakt `stepper://` niezależny od platformy. Może być implementowany przez Python/RPi GPIO, Pololu Tic, Node proxy, C/ESP-IDF na ESP32-P4 albo dowolny inny runtime.

```yaml markpact:contract
apiVersion: urisys.io/v1
kind: UriContract
metadata:
  id: uristepper.contract
  version: 1.0.0
  title: Stepper Motor URI Contract
scheme: stepper
resources:
  - pattern: stepper://{device}/axis/{axis}
commands:
  - id: stepper.enable
    pattern: stepper://{device}/axis/{axis}/command/enable
    input:
      type: object
      properties: {}
    side_effects: true
    requires_approval: true
    emits: [stepper.enable.completed]
  - id: stepper.disable
    pattern: stepper://{device}/axis/{axis}/command/disable
    input:
      type: object
      properties: {}
    side_effects: true
    requires_approval: true
    emits: [stepper.disable.completed]
  - id: stepper.stop
    pattern: stepper://{device}/axis/{axis}/command/stop
    input:
      type: object
      properties: {}
    side_effects: true
    requires_approval: true
    emits: [stepper.stop.completed]
  - id: stepper.move_relative
    pattern: stepper://{device}/axis/{axis}/command/move-relative
    input:
      type: object
      required: [steps, direction]
      properties:
        steps:
          type: integer
          minimum: 1
        direction:
          type: string
          enum: [cw, ccw]
        speed_sps:
          type: number
          minimum: 1
        acceleration_sps2:
          type: number
          minimum: 1
    side_effects: true
    requires_approval: true
    emits: [stepper.move_relative.completed, stepper.move_relative.failed]
  - id: stepper.move_absolute
    pattern: stepper://{device}/axis/{axis}/command/move-absolute
    input:
      type: object
      required: [position]
      properties:
        position:
          type: integer
        speed_sps:
          type: number
          minimum: 1
    side_effects: true
    requires_approval: true
    emits: [stepper.move_absolute.completed, stepper.move_absolute.failed]
  - id: stepper.home
    pattern: stepper://{device}/axis/{axis}/command/home
    input:
      type: object
      properties:
        direction:
          type: string
          enum: [cw, ccw]
        speed_sps:
          type: number
          minimum: 1
    side_effects: true
    requires_approval: true
    emits: [stepper.home.completed, stepper.home.failed]
queries:
  - id: stepper.status
    pattern: stepper://{device}/axis/{axis}/query/status
    output:
      type: object
      properties:
        device: {type: string}
        axis: {type: string}
        enabled: {type: boolean}
        position_steps: {type: integer}
        moving: {type: boolean}
        driver: {type: string}
events:
  - id: stepper.move_relative.completed
  - id: stepper.move_absolute.completed
  - id: stepper.home.completed
  - id: stepper.stop.completed
```
