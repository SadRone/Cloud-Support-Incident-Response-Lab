# Cloud Support Incident Response Lab

A hands-on cloud support portfolio project built with WSL2, Docker Compose, Nginx, Redis, Prometheus, Grafana, Alertmanager, and Blackbox Exporter.

This lab creates a small production-style environment on a local Windows computer. It is designed to develop practical experience in Linux operations, container management, service health checks, application monitoring, log analysis, network troubleshooting, incident investigation, and service recovery.

The environment runs locally through WSL2 and Docker Desktop, so no paid cloud resources are required.

---

## Project Objectives

This project is intended to demonstrate the following cloud support and infrastructure support skills:

- Installing and configuring WSL2
- Accessing an Ubuntu environment from Windows Terminal
- Integrating Docker Desktop with Ubuntu on WSL2
- Running containerized services with Docker Compose
- Managing multiple connected application services
- Understanding reverse proxy and backend service communication
- Checking container health and service readiness
- Monitoring application availability and performance
- Investigating service outages through logs and metrics
- Reproducing and resolving dependency failures
- Diagnosing network and upstream configuration problems
- Investigating high application latency
- Writing incident reports and operational runbooks

The following incidents will be reproduced and investigated in later stages:

1. Application container outage
2. Redis dependency failure
3. Nginx upstream configuration error
4. High application latency

---

## Technology Stack

| Component | Purpose |
|---|---|
| WSL2 | Provides a Linux environment inside Windows |
| Ubuntu | Linux distribution used for command-line operations |
| Docker Desktop | Runs and manages the Docker engine |
| Docker Compose | Defines and runs the multi-container environment |
| Nginx | Acts as the reverse proxy and entry point |
| Python application | Provides the sample backend service |
| Gunicorn | Runs the Python web application |
| Redis | Provides an application dependency and data service |
| Prometheus | Collects application and infrastructure metrics |
| Grafana | Visualizes metrics through dashboards |
| Blackbox Exporter | Checks endpoint availability and response behavior |
| Alertmanager | Receives and manages Prometheus alerts |
| Bash | Executes setup, validation, traffic, and incident scripts |

---

## Architecture Overview

```text
                           User Request
                                |
                                v
                         Nginx Reverse Proxy
                                |
                                v
                      Python Application Container
                                |
                                v
                              Redis


                Prometheus <---- Application Metrics
                    |
                    +---- Blackbox Exporter
                    |
                    +---- Alertmanager
                    |
                    v
                  Grafana
```

### Request Flow

1. A user sends an HTTP request to Nginx.
2. Nginx forwards the request to the application container.
3. The application communicates with Redis when required.
4. Prometheus collects application and service metrics.
5. Blackbox Exporter checks endpoint availability.
6. Grafana visualizes the collected metrics.
7. Alertmanager receives alerts when defined conditions are met.

---

# Environment Setup

## 1. Prerequisites

Install the following components before starting the project:

- Windows 10 or Windows 11
- Windows Subsystem for Linux 2
- Ubuntu for WSL
- Docker Desktop
- Docker Compose
- Windows Terminal
- Visual Studio Code, optional
- Git, optional

Docker Desktop must remain running while Docker commands are used inside Ubuntu.

---

## 2. Install WSL2 and Ubuntu

Open Windows PowerShell as an administrator and run:

```powershell
wsl --install
```

This command installs WSL and the default Ubuntu distribution.

After the installation is complete, restart Windows if requested.

Check the installed WSL distributions:

```powershell
wsl -l -v
```

The expected result should show Ubuntu using WSL version 2:

```text
NAME      STATE      VERSION
Ubuntu    Running    2
```

If Ubuntu is using WSL version 1, convert it to WSL2:

```powershell
wsl --set-version Ubuntu 2
```

---

## 3. Access Ubuntu through Windows Terminal

Ubuntu can be opened directly from PowerShell:

```powershell
wsl -d Ubuntu
```

Before entering Ubuntu, the Windows PowerShell prompt normally appears similar to:

```text
PS C:\Users\username>
```

After successfully entering Ubuntu, the prompt changes to a Linux-style prompt:

```text
username@computer:/mnt/c/Users/username$
```

This confirms that the commands are now being executed inside Ubuntu rather than Windows PowerShell.

<img width="751" height="242" alt="Accessing Ubuntu through Windows Terminal" src="https://github.com/user-attachments/assets/0041265d-5865-47d4-abb5-5190c1385c57" />

---

## 4. Configure Docker Desktop

Start Docker Desktop from the Windows Start menu.

Wait until the Docker engine has fully started before executing Docker commands.

Open Docker Desktop settings and navigate to:

```text
Settings
→ Resources
→ WSL Integration
```

Enable:

```text
Enable integration with my default WSL distro
```

Docker Desktop must be configured to use the Ubuntu WSL distribution.

<img width="1592" height="895" alt="Docker Desktop settings" src="https://github.com/user-attachments/assets/2605b097-3a01-4e7a-ade7-865ce19ada18" />

Select the WSL integration settings under the Resources section.

<img width="1078" height="553" alt="Docker Desktop WSL integration settings" src="https://github.com/user-attachments/assets/6f055f6c-e1c5-43f8-bc46-52f80f09a7db" />

Enable the Ubuntu distribution and select:

```text
Apply & restart
```

<img width="1482" height="683" alt="Ubuntu integration enabled in Docker Desktop" src="https://github.com/user-attachments/assets/3d48b732-2087-4e8b-92fd-e42f58bca8f8" />

After Docker Desktop restarts, wait until the Docker engine is running again.

---

## 5. Verify Docker inside Ubuntu

Open Ubuntu:

```powershell
wsl -d Ubuntu
```

Check the Docker version:

```bash
docker --version
```

Check the Docker Compose version:

```bash
docker compose version
```

Run the official Docker test image:

```bash
docker run --rm hello-world
```

The command must use `hello-world` with a hyphen.

A successful result displays:

```text
Hello from Docker!

This message shows that your installation appears to be working correctly.
```

This test confirms that:

1. The Docker client is available inside Ubuntu.
2. Ubuntu can communicate with the Docker Desktop engine.
3. Docker can download an image from Docker Hub.
4. Docker can create and start a container.
5. The container can run and return output.

---

# Project File Preparation

## 6. Locate the Project Folder

The project was initially stored inside the Windows file system.

Windows drives are accessible from Ubuntu under `/mnt`.

For example:

```text
C:\Users\username
```

is available inside Ubuntu as:

```text
/mnt/c/Users/username
```

A project folder can be located with:

```bash
find /mnt/c/Users/username -maxdepth 6 -type d -iname "cloud-support-incident-lab*" 2>/dev/null
```

The command searches for matching directories while suppressing permission-related error messages.

---

## 7. Copy the Project into the WSL File System

Docker projects generally perform more reliably when stored inside the native WSL Linux file system rather than directly under `/mnt/c`.

Create a projects directory inside the Ubuntu home folder:

```bash
mkdir -p ~/projects
```

Copy the project from its Windows path:

```bash
cp -a "/mnt/c/path/to/cloud-support-incident-lab" ~/projects/
```

Example:

```bash
cp -a "/mnt/c/Users/username/Desktop/cloud-support-incident-lab" ~/projects/
```

Move into the copied project folder:

```bash
cd ~/projects/cloud-support-incident-lab
```

Check the current path:

```bash
pwd
```

Expected result:

```text
/home/username/projects/cloud-support-incident-lab
```

List the project contents:

```bash
ls -la
```

The repository should contain files and folders similar to:

```text
.env.example
.gitignore
README.md
README_KO.md
app
compose.yml
docs
grafana
nginx
prometheus
scripts
```

<img width="1432" height="441" alt="Copying the project into the WSL file system" src="https://github.com/user-attachments/assets/cff5e1a5-d060-4279-8d40-b7527655f2e3" />

---

## 8. Confirm the Correct Project Path

Verify that the Docker Compose file exists:

```bash
test -f compose.yml && echo "PROJECT FOUND" || echo "WRONG FOLDER"
```

Expected output:

```text
PROJECT FOUND
```

This confirms that the terminal is currently located in the correct project directory.

---

## 9. Confirm Docker Connectivity Again

Before starting the lab, verify that Docker is still accessible from Ubuntu:

```bash
docker info >/dev/null && echo "DOCKER READY"
```

Expected result:

```text
DOCKER READY
```

Some Docker Desktop environments may display warning messages before `DOCKER READY`. The important result is that the command successfully communicates with the Docker daemon.

<img width="1465" height="225" alt="Docker connectivity confirmed inside Ubuntu" src="https://github.com/user-attachments/assets/e8132aa5-6191-42ef-8b62-08dad4b84343" />

---

# Docker Compose Preparation

## 10. Create the Local Environment File

The repository contains an example environment file.

Create the local `.env` file:

```bash
test -f .env || cp .env.example .env
```

Display the file:

```bash
cat .env
```

The environment file contains values used by Docker Compose, including the project name and Grafana credentials.

Example:

```text
COMPOSE_PROJECT_NAME=cloud-support-lab
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=cloudsupport123
```

The `.env` file should remain excluded from Git when it contains private values.

---

## 11. Review the Docker Compose Configuration

Validate the Docker Compose file:

```bash
docker compose config --quiet
```

If no error is displayed, the Compose configuration is valid.

Display the configured services:

```bash
docker compose config --services
```

The project should contain the following services:

```text
nginx
app
redis
prometheus
blackbox
alertmanager
grafana
```

### Service Responsibilities

#### Nginx

Nginx acts as the public entry point for the application. It receives requests from the user and forwards them to the backend application container.

#### Application

The application container runs the sample web service. It provides endpoints for health checks, readiness checks, metrics, errors, and latency simulations.

#### Redis

Redis acts as an external dependency for the application. Stopping Redis allows the project to demonstrate the difference between application liveness and service readiness.

#### Prometheus

Prometheus collects metrics from the application and monitoring components.

#### Blackbox Exporter

Blackbox Exporter checks whether HTTP endpoints are reachable and measures their response behavior.

#### Grafana

Grafana visualizes Prometheus metrics through dashboards.

#### Alertmanager

Alertmanager receives alerts generated by Prometheus alerting rules.

---

# Starting the Lab

## 12. Run the Setup Script

Start the complete environment:

```bash
bash scripts/setup.sh
```

The setup script performs the following operations:

1. Checks whether Docker is available
2. Creates the `.env` file if necessary
3. Builds the Python application image
4. Downloads the required Docker images
5. Creates the Docker networks
6. Creates persistent Docker volumes
7. Starts all defined containers
8. Waits for the services to initialize
9. Checks the application health status
10. Confirms that the lab is ready

The first execution can take several minutes because Docker must download multiple images and build the application container.

<img width="1493" height="488" alt="Starting the Cloud Support Incident Response Lab" src="https://github.com/user-attachments/assets/ae2de7ab-4f3b-40e4-a4a8-541ad45e3074" />

During the setup process, Docker creates several resources.

### Docker Networks

```text
cloud-support-lab_frontend
cloud-support-lab_backend
cloud-support-lab_monitoring
```

The networks separate traffic according to service responsibilities.

### Docker Volumes

```text
cloud-support-lab_redis-data
cloud-support-lab_prometheus-data
cloud-support-lab_grafana-data
cloud-support-lab_alertmanager-data
```

The volumes preserve service data when containers are restarted or recreated.

### Docker Containers

```text
csl-nginx
csl-app
csl-redis
csl-prometheus
csl-blackbox
csl-alertmanager
csl-grafana
```

---

## 13. Successful Deployment

A successful deployment displays:

```text
[OK] Lab is ready
```

The setup script also displays the local service addresses:

```text
App:          http://localhost:8080
Grafana:      http://localhost:3000
Prometheus:   http://localhost:9090
Alertmanager: http://localhost:9093
```

At this point:

- The application image has been built.
- All required Docker images have been downloaded.
- Three Docker networks have been created.
- Persistent data volumes have been created.
- Seven containers have been started.
- Redis has passed its health check.
- The application has passed its health check.
- Nginx is accepting incoming requests.
- Prometheus is collecting metrics.
- Grafana is available for dashboard access.
- Alertmanager is running.
- Blackbox Exporter is ready to perform endpoint checks.

The initial infrastructure setup is now complete.

---

# Available Services

## Application

```text
http://localhost:8080
```

The application is accessed through the Nginx reverse proxy.

## Grafana

```text
http://localhost:3000
```

Default login credentials:

```text
Username: admin
Password: cloudsupport123
```

## Prometheus

```text
http://localhost:9090
```

Prometheus can be used to inspect:

- Scrape targets
- Application metrics
- Blackbox metrics
- Prometheus rules
- Active and pending alerts

## Alertmanager

```text
http://localhost:9093
```

Alertmanager displays received alerts and their current status.

---

# Current Project Status

The environment setup phase has been completed successfully.

Completed tasks:

- WSL2 installation
- Ubuntu configuration
- Docker Desktop installation
- Docker and WSL2 integration
- Docker connectivity testing
- Project transfer into the WSL file system
- Environment configuration
- Docker Compose validation
- Application image build
- Network creation
- Volume creation
- Container deployment
- Service health verification
- Successful lab startup

Current status:

```text
[OK] Lab is ready
```

---

# Next Stage

The next stage of the project will include:

1. Verifying all running containers
2. Testing application health endpoints
3. Accessing Grafana and Prometheus
4. Generating normal application traffic
5. Establishing baseline monitoring data
6. Reproducing an application outage
7. Reproducing a Redis dependency failure
8. Reproducing an Nginx upstream configuration error
9. Reproducing high application latency
10. Investigating each incident through logs and metrics
11. Recovering each affected service
12. Writing incident response reports
13. Documenting root causes and preventive actions

These tasks will be added after the initial environment has been validated.
