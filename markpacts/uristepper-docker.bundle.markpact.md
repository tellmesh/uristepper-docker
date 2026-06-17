# UriBundle: uristepper-docker

Bundle spinający kontrakt, implementację Python mock i profil urządzenia Docker.

```yaml markpact:bundle
apiVersion: urisys.io/v1
kind: UriBundle
metadata:
  id: uristepper-docker.bundle
  version: 0.1.0
imports:
  contracts:
    - ./uristepper.contract.markpact.md
  implementations:
    - ./uristepper-python-mock.markpact.md
overlays:
  device_profiles:
    - ../config/device-profile.json
  flows:
    - ../flows/move-test.uri.flow.yaml
install:
  target: docker-compose
  compose_file: ../docker-compose.yml
```
