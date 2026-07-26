# Incident Response Runbook

Use the same sequence for every scenario.

## 1. Confirm the user impact

```bash
curl -i http://localhost:8080/health
curl -i http://localhost:8080/ready
curl -i http://localhost:8080/work
```

Record the HTTP status, response body, and time.

## 2. Check container health

```bash
docker compose ps
docker stats --no-stream
docker inspect csl-app --format '{{json .State.Health}}'
```

## 3. Inspect logs

```bash
docker compose logs nginx --since=10m
docker compose logs app --since=10m
docker compose logs redis --since=10m
```

Look for status codes, upstream connection failures, timeouts, DNS errors, and dependency exceptions.

## 4. Test DNS and ports from inside the network

```bash
docker compose exec app getent hosts redis
docker compose exec app python -c "import socket; print(socket.create_connection(('redis',6379),2))"
docker compose exec nginx getent hosts app
docker compose exec nginx wget -qO- http://app:5000/health
```

## 5. Check monitoring

- Prometheus targets: `http://localhost:9090/targets`
- Prometheus alerts: `http://localhost:9090/alerts`
- Alertmanager: `http://localhost:9093`
- Grafana: `http://localhost:3000`

## 6. Recover safely

Restart only the failed component when possible, then validate from the user-facing endpoint.

```bash
docker compose restart <service>
./scripts/status.sh
```

## 7. Write the incident report

Document:

1. Impact
2. Detection
3. Timeline
4. Evidence
5. Root cause
6. Resolution
7. Prevention
8. What you learned
