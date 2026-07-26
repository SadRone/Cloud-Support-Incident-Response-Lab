#!/usr/bin/env bash
set -euo pipefail

BASE_URL=${BASE_URL:-http://localhost:8080}
COUNT=${1:-60}

echo "Generating $COUNT requests against $BASE_URL"
for i in $(seq 1 "$COUNT"); do
  curl -fsS "$BASE_URL/work" >/dev/null || true

  if (( i % 10 == 0 )); then
    curl -sS "$BASE_URL/error" >/dev/null || true
  fi

  if (( i % 15 == 0 )); then
    curl -fsS "$BASE_URL/slow?seconds=2" >/dev/null || true
  fi

  sleep 0.2
done

echo "Traffic generation complete. Open Grafana: http://localhost:3000"
