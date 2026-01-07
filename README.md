# UniFi OS Server

[![Docker Hub](https://img.shields.io/docker/v/unifi-os-rpi/unifi-os-server?label=Docker%20Hub)](https://hub.docker.com/r/unifi-os-rpi/unifi-os-server)
[![CI Status](https://img.shields.io/github/actions/workflow/status/unifi-os-rpi/unifi-os-server/ci.yml?branch=main)](https://github.com/unifi-os-rpi/unifi-os-server/actions)
[![License](https://img.shields.io/github/license/unifi-os-rpi/unifi-os-server)](LICENSE)
[![Platforms](https://img.shields.io/badge/platforms-linux%2Farm64%2Famd64-blue)](https://hub.docker.com/r/unifi-os-rpi/unifi-os-server/tags)

Deploy **UniFi OS Server** on Raspberry Pi (ARM64) or x86_64 (AMD64) using Docker. UniFi OS is Ubiquiti's next-generation platform that replaces the legacy UniFi Network Controller.

## Features

- Multi-architecture support: ARM64 (Raspberry Pi) and AMD64 (x86_64)
- Full UniFi OS Server with systemd inside container
- Pre-configured Docker Compose for easy deployment
- Backup and restore utilities included
- Automated CI/CD with security scanning

## Quick Start

```bash
# Clone and enter repository
git clone https://github.com/unifi-os-rpi/unifi-os-server.git
cd unifi-os-server

# Configure environment
cp .env.example .env
# Edit .env and set UOS_SYSTEM_IP to your Pi's hostname/IP

# Run installation script
sudo ./scripts/install.sh

# Start services
docker compose up -d
```

Access UniFi OS at: `https://<UOS_SYSTEM_IP>:11443`

## Supported Tags

| Tag | Description |
|-----|-------------|
| `latest` | Latest stable release |
| `5` | UniFi OS 5.x |
| `5.0.6` | Specific version |

## Management Commands

```bash
# Start services
docker compose up -d

# Stop services
docker compose stop

# Restart services
docker compose restart

# View logs
docker logs -f unifi-os-server

# Create backup
./scripts/backup.sh

# Restore from backup
sudo ./scripts/restore.sh /opt/unifi-os/backups/unifi-os-backup_*.tar.gz

# Update to latest version
docker compose pull && docker compose up -d
```

## Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| Raspberry Pi | Pi 4 | Pi 4 (4GB+) or Pi 5 |
| OS | Raspberry Pi OS 64-bit | Raspberry Pi OS 64-bit (Bookworm) |
| RAM | 2GB | 4GB+ |
| Storage | USB SSD | USB 3.0 SSD |

**Note:** Docker Engine v28+ no longer supports 32-bit ARM. You must use a 64-bit OS.

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `UOS_SYSTEM_IP` | Hostname/IP for device adoption | Required |
| `TZ` | Timezone | UTC |
| `UOS_UUID` | Unique system identifier | Auto-generated |
| `DATA_DIR` | Persistent data directory | /opt/unifi-os |

### Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| 11443 | TCP | UniFi OS GUI/API |
| 8080 | TCP | Device command/control |
| 3478 | UDP | STUN for adoption |
| 10001 | UDP | Device discovery |

## Contributing

Contributions are welcome! Please see our [Contributing Guide](.github/CONTRIBUTING.md) for details.

## Security

For security vulnerabilities, please see our [Security Policy](.github/SECURITY.md).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Credits

- [lemker/unifi-os-server](https://github.com/lemker/unifi-os-server) - Base Docker image
- [Ubiquiti](https://www.ui.com) - UniFi OS platform
