#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

echo "=== Containers ==="
docker compose ps

echo
echo "=== HTTP checks ==="
for url in \
  http://localhost:8080/nginx-health \
  http://localhost:8080/health \
  http://localhost:8080/ready \
  http://localhost:9090/-/healthy \
  http://localhost:3000/api/health; do
  code=$(curl -sS -o /tmp/csl-response.txt -w "%{http_code}" "$url" || true)
  printf "%-42s %s\n" "$url" "$code"
done
