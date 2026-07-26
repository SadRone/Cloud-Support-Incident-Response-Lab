#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if ! command -v docker >/dev/null 2>&1; then
  echo "[ERROR] Docker CLI was not found. Install Docker Desktop and enable WSL integration."
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "[ERROR] Docker daemon is not available. Start Docker Desktop."
  exit 1
fi

if [[ ! -f .env ]]; then
  cp .env.example .env
  echo "[INFO] Created .env from .env.example"
fi

echo "[INFO] Building and starting the lab..."
docker compose up -d --build

echo "[INFO] Waiting for services..."
for _ in {1..30}; do
  if curl -fsS http://localhost:8080/ready >/dev/null 2>&1; then
    echo "[OK] Lab is ready"
    echo "App:          http://localhost:8080"
    echo "Grafana:      http://localhost:3000"
    echo "Prometheus:   http://localhost:9090"
    echo "Alertmanager: http://localhost:9093"
    exit 0
  fi
  sleep 2
done

echo "[ERROR] Lab did not become ready. Run: docker compose ps && docker compose logs --tail=100"
exit 1
