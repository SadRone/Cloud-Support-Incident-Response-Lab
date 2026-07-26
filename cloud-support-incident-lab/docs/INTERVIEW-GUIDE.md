# Interview Guide

## 30-second explanation

I built a local incident-response environment on WSL2 using Docker Compose. Nginx receives requests, a Flask application depends on Redis, and Prometheus, Blackbox Exporter, Grafana, and Alertmanager provide monitoring. I deliberately reproduced four incidents and used container status, Linux commands, logs, DNS and port tests, health endpoints, metrics, and alerts to isolate and recover each issue.

## Questions you should be able to answer

1. Why can `/health` return 200 while `/ready` returns 503?
2. What causes an Nginx 502 Bad Gateway?
3. How does Docker Compose resolve the hostname `redis`?
4. Why is Redis placed on an internal backend network?
5. What is the difference between container restart and image rebuild?
6. How did Prometheus detect a problem that Nginx's own health check missed?
7. What evidence proves the root cause rather than merely correlating with it?
8. What would change when moving this architecture to AWS?

## AWS mapping

| Local lab | AWS equivalent |
|---|---|
| Nginx | Application Load Balancer or reverse proxy on ECS/EC2 |
| Flask container | ECS task, EKS pod, or EC2 workload |
| Redis | ElastiCache for Redis |
| Docker network | VPC subnets, security groups, service discovery |
| Prometheus | Amazon Managed Service for Prometheus or self-managed Prometheus |
| Grafana | Amazon Managed Grafana or self-managed Grafana |
| Alertmanager | SNS, PagerDuty integration, or Alertmanager |
| Docker volume | EBS, EFS, or managed service storage |
