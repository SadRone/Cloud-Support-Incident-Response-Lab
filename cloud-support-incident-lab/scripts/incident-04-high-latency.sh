#!/usr/bin/env bash
set -euo pipefail

BASE_URL=${BASE_URL:-http://localhost:8080}
COUNT=${1:-30}

echo "[INCIDENT 04] Generating slow requests..."
for _ in $(seq 1 "$COUNT"); do
  curl -fsS "$BASE_URL/slow?seconds=2" >/dev/null &
  sleep 0.15
done
wait
cat <<'MSG'

Expected observations:
  Grafana p95 latency rises above 1.5 seconds.
  Prometheus HighP95Latency may enter pending/firing state.

Triage:
  docker compose logs app --since=5m
  curl -s http://localhost:9090/api/v1/query?query=histogram_quantile%280.95%2Csum%20by%20%28le%29%20%28rate%28http_request_duration_seconds_bucket%5B2m%5D%29%29%29
MSG
