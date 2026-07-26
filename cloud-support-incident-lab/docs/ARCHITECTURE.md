# Architecture

```text
Browser / curl
      |
      v
Nginx reverse proxy :8080
      |
      v
Flask + Gunicorn app :5000 ----> Redis :6379
      |
      +---- /metrics <---- Prometheus :9090 ----> Alertmanager :9093
                                      |
                                      v
                                Grafana :3000

Blackbox Exporter probes Nginx health and readiness endpoints.
```

## Network segmentation

- `frontend`: Nginx, app, Prometheus, Blackbox Exporter
- `backend`: app and Redis only, marked `internal: true`
- `monitoring`: Prometheus, Grafana, Alertmanager, Blackbox Exporter

This structure demonstrates service discovery through Docker DNS, separation of public and private services, dependency checks, metrics, alerting, and incident triage.
