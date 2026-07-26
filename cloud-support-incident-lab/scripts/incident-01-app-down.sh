#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

echo "[INCIDENT 01] Stopping the application container..."
docker compose stop app
cat <<'MSG'

Expected symptoms:
  curl -i http://localhost:8080/ready
  docker compose ps
  docker compose logs nginx --tail=50

Recovery:
  docker compose start app
  ./scripts/status.sh

Record screenshots of:
  1. Nginx 502 response
  2. docker compose ps showing app stopped
  3. Prometheus alert
  4. Successful recovery
MSG
