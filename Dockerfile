# uristepper-docker OCI image
#
# Build from tellmesh workspace root:
#   docker build -f uristepper-docker/Dockerfile /home/tom/github/tellmesh
#
FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    URISYS_DEVICE_PROFILE=/app/config/device-profile.json \
    URISYS_EVENTS_PATH=/data/events.jsonl \
    URISYS_STATE_PATH=/data/stepper_state.json \
    URISYS_NODE_ID=uristepper-docker

WORKDIR /build
COPY urisysedge /build/urisysedge
COPY uristepper /build/uristepper
COPY uristepper-docker /build/uristepper-docker
RUN pip install --no-cache-dir \
    -e /build/urisysedge \
    -e /build/uristepper \
    -e /build/uristepper-docker \
    && mkdir -p /data
WORKDIR /build/uristepper-docker
EXPOSE 8790
CMD ["python", "-m", "uristepperedge", "serve", "--host", "0.0.0.0", "--port", "8790"]
