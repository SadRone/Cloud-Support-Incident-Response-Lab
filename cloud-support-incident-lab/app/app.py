import json
import logging
import os
import time
from typing import Any

from flask import Flask, Response, jsonify, request
from prometheus_client import CONTENT_TYPE_LATEST, Counter, Gauge, Histogram, generate_latest
from redis import Redis
from redis.exceptions import RedisError

APP_VERSION = os.getenv("APP_VERSION", "dev")
REDIS_HOST = os.getenv("REDIS_HOST", "redis")
REDIS_PORT = int(os.getenv("REDIS_PORT", "6379"))
LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO").upper()

logging.basicConfig(level=LOG_LEVEL, format="%(message)s")
logger = logging.getLogger("cloud-support-lab")

app = Flask(__name__)
redis_client = Redis(host=REDIS_HOST, port=REDIS_PORT, decode_responses=True, socket_timeout=1)

REQUESTS = Counter(
    "http_requests_total",
    "Total HTTP requests",
    ["method", "endpoint", "status"],
)
LATENCY = Histogram(
    "http_request_duration_seconds",
    "HTTP request duration in seconds",
    ["method", "endpoint"],
    buckets=(0.05, 0.1, 0.25, 0.5, 1, 2, 5, 10),
)
DEPENDENCY_UP = Gauge(
    "app_dependency_up",
    "Dependency health status",
    ["dependency"],
)


def log_event(event: str, **fields: Any) -> None:
    payload = {
        "event": event,
        "service": "cloud-support-app",
        "version": APP_VERSION,
        **fields,
    }
    logger.info(json.dumps(payload, ensure_ascii=False))


@app.before_request
def start_timer() -> None:
    request._started_at = time.perf_counter()  # type: ignore[attr-defined]


@app.after_request
def record_metrics(response: Response) -> Response:
    endpoint = request.endpoint or "unknown"
    elapsed = time.perf_counter() - getattr(request, "_started_at", time.perf_counter())
    REQUESTS.labels(request.method, endpoint, str(response.status_code)).inc()
    LATENCY.labels(request.method, endpoint).observe(elapsed)
    log_event(
        "http_request",
        method=request.method,
        path=request.path,
        endpoint=endpoint,
        status=response.status_code,
        duration_ms=round(elapsed * 1000, 2),
        remote_addr=request.headers.get("X-Forwarded-For", request.remote_addr),
    )
    return response


@app.get("/")
def index():
    return jsonify(
        service="cloud-support-incident-lab",
        version=APP_VERSION,
        endpoints=["/health", "/ready", "/work", "/slow?seconds=3", "/error", "/metrics"],
    )


@app.get("/health")
def health():
    return jsonify(status="UP", service="app"), 200


@app.get("/ready")
def ready():
    try:
        redis_client.ping()
        DEPENDENCY_UP.labels("redis").set(1)
        return jsonify(status="READY", dependencies={"redis": "UP"}), 200
    except RedisError as exc:
        DEPENDENCY_UP.labels("redis").set(0)
        log_event("dependency_failure", dependency="redis", error=str(exc))
        return jsonify(status="NOT_READY", dependencies={"redis": "DOWN"}), 503


@app.get("/work")
def work():
    try:
        current = redis_client.incr("work_requests")
        DEPENDENCY_UP.labels("redis").set(1)
        return jsonify(message="Work completed", total_work_requests=current), 200
    except RedisError as exc:
        DEPENDENCY_UP.labels("redis").set(0)
        log_event("work_failed", dependency="redis", error=str(exc))
        return jsonify(error="Redis dependency unavailable"), 503


@app.get("/slow")
def slow():
    try:
        seconds = float(request.args.get("seconds", "3"))
    except ValueError:
        return jsonify(error="seconds must be numeric"), 400
    seconds = max(0.0, min(seconds, 10.0))
    time.sleep(seconds)
    return jsonify(message="Slow request completed", delay_seconds=seconds), 200


@app.get("/error")
def error():
    return jsonify(error="Simulated application error", incident="HTTP_500_DEMO"), 500


@app.get("/metrics")
def metrics():
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)
