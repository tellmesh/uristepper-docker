# uristepper-docker

Minimalny, samodzielny przykład `stepper://` uruchamiany przez Docker Compose.

Cel przykładu:

- pokazać routing `URL -> URI -> handler`,
- rozdzielić transport HTTP od komendy `stepper://`,
- mieć testowalny mock bez sprzętu,
- pokazać miejsce na RPi GPIO i później ESP32-P4,
- dać Markpact contract/implementation do publikacji na `markpact.com`.

## Szybki start

```bash
cd uristepper-docker
./scripts/test-local.sh
```

Docker:

```bash
docker compose up --build uristepper
```

W drugim terminalu:

```bash
./scripts/call-http.sh
```

Test e2e w Dockerze:

```bash
./scripts/test-docker.sh
```

## Endpointy

```text
GET  /health
GET  /routes
GET  /events
POST /uri/call
POST /uri/explain
```

Przykład:

```bash
curl -X POST http://127.0.0.1:8791/uri/call \
  -H 'Content-Type: application/json' \
  -d '{
    "uri": "stepper://machine-01/axis/x/command/move-relative",
    "payload": {"steps": 200, "direction": "cw", "speed_sps": 250},
    "context": {"approved": true}
  }'
```

## URI vs URL

URL transportowy:

```text
http://127.0.0.1:8791/uri/call
```

URI komendy:

```text
stepper://machine-01/axis/x/command/move-relative
```

Dzięki temu aplikacja, flow, shell i frontend nie zależą od tego, czy wykonanie jest w Dockerze, na RPi, przez USB, czy na ESP32-P4.

## Stack

```txt
../uristepper/            → stepper:// capability pack (manifest-first)
../uristepperedge/        → HTTP edge (:8790) for device hosts
flows/*.uri.flow.yaml     → local flow runner
config/device-profile.json
markpacts/                → docker bundle markpact
../uristepper/markpacts/  → contract + pack + implementations
```

## Device profile

Konfiguracja konkretnego urządzenia jest w:

```text
config/device-profile.json
```

Tam znajdują się osie, driver, piny i limity bezpieczeństwa:

```json
{
  "axes": {
    "x": {
      "driver": "mock",
      "step_pin": 17,
      "dir_pin": 27,
      "enable_pin": 22
    }
  },
  "safety": {
    "x": {
      "max_speed_sps": 1200,
      "max_single_move_steps": 10000
    }
  }
}
```

W Dockerze driver to `mock`. Na RPi można przygotować profil z:

```json
"driver": "rpi-gpio-step-dir"
```

Przykład jest w:

```text
config/device-profile.rpi3.example.json
```

## Flow

Flow jest w:

```text
flows/move-test.uri.flow.yaml
```

Uruchomienie lokalnie:

```bash
export URISYS_DEVICE_PROFILE=config/device-profile.json
export URISYS_EVENTS_PATH=data/events.jsonl
python -m uristepperedge \
  --device-config config/device-profile.json \
  --events data/events.jsonl \
  flow flows/move-test.uri.flow.yaml \
  --approve \
  --dry-run
```

## Markpact

Contract, pack and implementations live in the capability repo:

```text
../uristepper/markpacts/uristepper.contract.markpact.md
../uristepper/markpacts/uristepper.pack.markpact.md
../uristepper/markpacts/uristepper-python-mock.markpact.md
../uristepper/markpacts/uristepper-rpi-gpio-python.markpact.md
```

Docker bundle (this repo):

```text
markpacts/uristepper-docker.bundle.markpact.md
```

Publikacja na `markpact.com`:

```bash
markpact publish ../uristepper/markpacts/uristepper.contract.markpact.md
markpact publish ../uristepper/markpacts/uristepper-python-mock.markpact.md
```

Potem inne urządzenia mogą pobrać kontrakt:

```bash
urisys markpact fetch https://markpact.com/raw/adam/uristepper.contract.markpact.md
```

## RPi GPIO

Ten przykład zawiera szkic drivera `rpi-gpio-step-dir`, ale Dockerowy obraz nie instaluje bibliotek GPIO. Na RPi możesz uruchomić runtime natywnie albo przygotować pochodny obraz z `gpiozero`/`lgpio`.

Ostrożnie: najpierw używaj `--dry-run`, ustaw limity prądu sterownika silnika i nie zasilaj silnika z Raspberry Pi.

## ESP32-P4

ESP32-P4 nie uruchamia Pythonowego handlera. Reużywany jest kontrakt `stepper://`, a implementacja powinna być osobnym firmware C/ESP-IDF:

```text
stepper://machine-01/axis/x/command/move-relative
  -> ESP32 HTTP /uri/call
  -> C handler
  -> RMT pulse train + GPIO DIR/ENABLE
```

Aplikacja nie zmienia URI. Zmieniasz tylko RouteMap/DeviceProfile.

## Ekosystem TellMesh

Orchestrator: **[urisys](https://github.com/tellmesh/urisys)** · Mapa: **[MESH.md](https://github.com/tellmesh/urisys/blob/main/docs/MESH.md)** · Model: **[ECOSYSTEM.md](https://github.com/tellmesh/urisys/blob/main/../docs/ECOSYSTEM.md)**

| Pole | Wartość |
|------|---------|
| **Warstwa** | Docker glue |
| **Scheme** | `stepper://` |
| **Zależności** | urirouter, uricore, uristepperedge |

Runtime edge: **`uri_control.edge`** w pakiecie **`uricore`** (legacy `urisysedge` usunięty 2026-06).
Router intencji: **`urirouter`** (`uri_router`) — resolve + HTTP/MQTT delegate.

<!-- end-ecosystem -->
