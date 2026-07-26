#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

echo "[INCIDENT 02] Stopping the Redis dependency..."
docker compose stop redis
cat <<'MSG'

Expected symptoms:
  curl -i http://localhost:8080/health   # Liveness remains UP
  curl -i http://localhost:8080/ready    # Readiness becomes 503
  docker compose logs app --tail=100
  docker network inspect cloud-support-lab_backend

Recovery:
  docker compose start redis
  sleep 5
  curl -i http://localhost:8080/ready

Key learning:
  Liveness and readiness are different. The process can be alive while a required dependency is unavailable.
MSG
