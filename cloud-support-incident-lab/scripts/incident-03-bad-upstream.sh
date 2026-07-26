#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

echo "[INCIDENT 03] Recreating Nginx with a deliberately wrong upstream port..."
docker compose -f compose.yml -f incidents/03-bad-upstream.compose.yml up -d --force-recreate nginx
cat <<'MSG'

Expected symptoms:
  curl -i http://localhost:8080/health
  docker compose logs nginx --tail=100
  docker compose exec nginx nginx -T
  docker compose exec app sh -c 'python -c "import socket; print(socket.gethostbyname(\"app\"))"'

Recovery:
  docker compose -f compose.yml up -d --force-recreate nginx
  ./scripts/status.sh

Root cause to document:
  Nginx was configured to reach app:5999 while Gunicorn listens on app:5000.
MSG
