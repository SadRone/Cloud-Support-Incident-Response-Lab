# WSL2 and Docker Desktop Setup

Run PowerShell as Administrator:

```powershell
wsl --install
wsl --update
wsl -l -v
```

After Ubuntu is installed:

```bash
sudo apt update
sudo apt install -y git curl
```

1. Install Docker Desktop for Windows.
2. Select the WSL 2 backend.
3. In Docker Desktop, enable integration for the Ubuntu distribution.
4. Open Ubuntu and keep the repository inside the Linux filesystem, for example `~/projects/cloud-support-incident-lab`, rather than under `/mnt/c/`, for better file performance.
5. Run:

```bash
cp .env.example .env
./scripts/setup.sh
```

Docker Desktop includes Docker Compose, so use the modern command `docker compose`, not the older `docker-compose` command.
