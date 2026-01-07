# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository deploys **UniFi OS Server** on a Raspberry Pi using Docker. UniFi OS is Ubiquiti's next-generation platform that replaces the legacy UniFi Network Controller.

Base image: `ghcr.io/lemker/unifi-os-server:5.0.6-linux-arm64`

## Commands

```bash
# Configure environment (required before first run)
cp .env.example .env
# Edit .env and set UOS_SYSTEM_IP to your Pi's hostname/IP

# Installation
sudo ./scripts/install.sh

# Start services
docker compose up -d

# Stop services
docker compose stop

# View logs
docker logs -f unifi-os-server

# Update to latest version
docker compose pull && docker compose up -d

# Create backup
./scripts/backup.sh

# Restore from backup
sudo ./scripts/restore.sh /path/to/backup.tar.gz
```

## Architecture

The container runs **systemd as PID 1**, which requires:
- `privileged: true` - For cgroup access
- `cgroupns: host` - Share host cgroup namespace
- `cap_add: SYS_ADMIN` - Full systemd capabilities
- `sysctls.net.ipv4.ip_unprivileged_port_start=0` - Allow low ports

Persistent data is stored in 5 volumes mapped from host storage:
- `/data` - UniFi OS system configuration
- `/var/log/unifi` - Application logs
- `/certs` - SSL certificates
- `/var/lib/unifi` - UniFi application data
- `/var/lib/mongodb` - MongoDB database (must be on USB SSD)

## Key Files

| File | Purpose |
|------|---------|
| `docker-compose.yaml` | Main deployment configuration |
| `scripts/install.sh` | Docker installation and setup |
| `scripts/backup.sh` | Backup utility |
| `scripts/restore.sh` | Restore utility |
| `.env.example` | Configuration template |

## Raspberry Pi Specifics

- **OS**: Must be 64-bit (aarch64). 32-bit deprecated for Docker v28+
- **Storage**: MongoDB data must be on USB SSD (SD cards will fail)
- **Memory**: 4GB+ recommended. 2GB may cause MongoDB restarts
- **Image tag**: Always use `-linux-arm64` suffix

## Ports (Required)

| Port | Protocol | Purpose |
|------|----------|---------|
| 11443 | TCP | UniFi OS GUI |
| 8080 | TCP | Device adoption |
| 3478 | UDP | STUN |
| 10001 | UDP | Device discovery |
