ARG PYTHON_BUILDER_IMAGE=dhi.io/python:3.13-alpine3.23-dev
ARG PYTHON_RUNTIME_IMAGE=dhi.io/python:3.13-alpine3.23

FROM ${PYTHON_BUILDER_IMAGE} AS builder

WORKDIR /build
COPY app/requirements.txt ./requirements.txt
RUN python -m venv /opt/venv \
    && /opt/venv/bin/pip install --no-cache-dir -r requirements.txt

FROM ${PYTHON_RUNTIME_IMAGE} AS runtime

ENV PATH="/opt/venv/bin:${PATH}" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1
WORKDIR /app
COPY --from=builder --chown=65532:65532 /opt/venv /opt/venv
COPY --chown=65532:65532 app/server.py /app/server.py
USER 65532:65532
EXPOSE 8080
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "server:app"]
