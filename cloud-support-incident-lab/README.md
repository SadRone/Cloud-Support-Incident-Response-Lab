# Cloud Support Incident Response Lab

A zero-cloud-cost portfolio project for entry-level Cloud Support Engineer and Technical Support Engineer roles. It runs locally on Windows through WSL2 and Docker Desktop.

## What this project proves

- Linux command-line troubleshooting inside WSL2
- Multi-container deployment with Docker Compose
- Reverse proxy and upstream troubleshooting with Nginx
- Docker DNS, ports, health checks, networks, and volumes
- Application dependency diagnosis with Redis
- Metrics collection with Prometheus and Blackbox Exporter
- Dashboarding with Grafana
- Alert routing with Alertmanager
- Structured incident reports and recovery validation

## Architecture

```text
Client -> Nginx -> Flask/Gunicorn -> Redis
              \-> health and readiness endpoints
Prometheus <- app metrics + Blackbox HTTP probes
Grafana    <- Prometheus
Prometheus -> Alertmanager
```

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for network details.

## Cost

The lab runs entirely on the local computer. There are no AWS, Azure, or Huawei Cloud charges. Docker Desktop licensing depends on the user's organization and use case, so review Docker's current terms before commercial workplace use.

## Quick start

### Prerequisites

- Windows 10 or 11 with WSL2
- Ubuntu on WSL2
- Docker Desktop with WSL integration enabled
- Git and curl

```bash
git clone <YOUR-GITHUB-REPOSITORY-URL>
cd cloud-support-incident-lab
cp .env.example .env
./scripts/setup.sh
```

Open:

| Component | URL |
|---|---|
| Application | http://localhost:8080 |
| Grafana | http://localhost:3000 |
| Prometheus | http://localhost:9090 |
| Alertmanager | http://localhost:9093 |

Default Grafana credentials are stored in `.env.example`. Change them in `.env` before taking screenshots or publishing a live deployment.

## Normal validation

```bash
./scripts/status.sh
curl -i http://localhost:8080/health
curl -i http://localhost:8080/ready
curl -i http://localhost:8080/work
./scripts/generate-traffic.sh 100
```

## Incident scenarios

### Incident 01: Application outage

```bash
./scripts/incident-01-app-down.sh
```

Diagnose an Nginx 502, stopped container, failed scrape target, and critical alert.

### Incident 02: Redis dependency outage

```bash
./scripts/incident-02-redis-down.sh
```

Compare liveness and readiness, inspect dependency exceptions, and validate recovery.

### Incident 03: Incorrect Nginx upstream port

```bash
./scripts/incident-03-bad-upstream.sh
```

Use Nginx logs, configuration inspection, Docker DNS, and direct port tests to prove the root cause.

### Incident 04: High latency

```bash
./scripts/incident-04-high-latency.sh 30
```

Use the Grafana p95 panel and Prometheus alert to detect a performance incident.

## Triage commands

```bash
docker compose ps
docker compose logs --since=10m
docker stats --no-stream
docker network ls
docker network inspect cloud-support-lab_frontend
docker compose exec nginx nginx -T
docker compose exec nginx wget -qO- http://app:5000/health
docker compose exec app getent hosts redis
docker compose exec app python -c "import socket; print(socket.create_connection(('redis',6379),2))"
```

## Incident documentation

Use [docs/INCIDENT-REPORT-TEMPLATE.md](docs/INCIDENT-REPORT-TEMPLATE.md) for every scenario. Store screenshots in `docs/screenshots/` and completed reports in `docs/reports/`.

## Resume bullet

See [docs/RESUME-BULLETS.md](docs/RESUME-BULLETS.md). Do not claim the project as completed until all incident reports and evidence are present.

## Cleanup

```bash
docker compose down
```

Delete all local data:

```bash
docker compose down -v
```

## Security notes

- This is a local training lab, not a production system.
- Do not expose Prometheus, Grafana, Redis, or Alertmanager directly to the public internet.
- Never commit `.env` or real credentials.
- Pin and regularly update container image versions.
