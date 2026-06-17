.PHONY: test docker up down call flow routes events

test:
	./scripts/test-local.sh

docker:
	./scripts/test-docker.sh

up:
	docker compose up --build uristepper

down:
	docker compose down -v

call:
	./scripts/call-http.sh

flow:
	PYTHONPATH=../packages/python:$$PWD/packages/python python -m uristepperedge --device-config config/device-profile.json --events data/events.jsonl flow flows/move-test.uri.flow.yaml --approve --dry-run

routes:
	PYTHONPATH=../packages/python:$$PWD/packages/python python -m uristepperedge --device-config config/device-profile.json routes

events:
	PYTHONPATH=../packages/python:$$PWD/packages/python python -m uristepperedge --device-config config/device-profile.json --events data/events.jsonl events
