# Cloud Support Incident Response Lab

신입 Cloud Support Engineer와 Technical Support Engineer 지원을 위한 무료 로컬 포트폴리오입니다. Windows의 WSL2와 Docker Desktop에서 실행됩니다.

## 핵심 구성

- Nginx: 외부 요청을 받는 리버스 프록시
- Flask와 Gunicorn: 애플리케이션 컨테이너
- Redis: 애플리케이션 의존성
- Prometheus: 메트릭 수집과 경보 조건 평가
- Blackbox Exporter: 사용자 관점의 HTTP 상태 확인
- Grafana: 장애와 성능 대시보드
- Alertmanager: 경보 라우팅

## 이 프로젝트로 입증하는 역량

- WSL2 기반 Linux 명령어 사용
- Docker 이미지, 컨테이너, 네트워크, 볼륨, 헬스체크
- Nginx 502와 upstream 장애 분석
- 서비스 DNS와 포트 연결 확인
- liveness와 readiness 차이
- 로그, 메트릭, 경보를 결합한 원인 분석
- 장애 복구 후 사용자 관점 검증
- Incident Report와 Runbook 작성

## 시작

```bash
cp .env.example .env
./scripts/setup.sh
```

접속 주소:

- 애플리케이션: http://localhost:8080
- Grafana: http://localhost:3000
- Prometheus: http://localhost:9090
- Alertmanager: http://localhost:9093

## 반드시 수행할 장애 실습

```bash
./scripts/incident-01-app-down.sh
./scripts/incident-02-redis-down.sh
./scripts/incident-03-bad-upstream.sh
./scripts/incident-04-high-latency.sh
```

각 장애마다 증상, 명령어, 로그, 근본 원인, 해결 방법, 복구 검증, 재발 방지책을 문서화해야 합니다. 단순히 코드를 GitHub에 올리는 것보다 직접 장애를 재현하고 분석한 증거가 채용에서 더 중요합니다.
