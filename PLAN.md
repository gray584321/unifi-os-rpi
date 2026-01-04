# Plan: UniFi OS on Raspberry Pi (Raspbian) Repository

## Overview

Create a repository to deploy **UniFi OS Server** on a Raspberry Pi running Raspbian using Docker. UniFi OS is Ubiquiti's next-generation platform that replaces the legacy UniFi Network Controller with additional features like Organizations, IdP Integration, and Site Magic SD-WAN.

Based on research of existing solutions:
- [lemker/unifi-os-server](https://github.com/lemker/unifi-os-server) - Full UniFi OS in Docker (x86_64/ARM64)
- [jacobalberty/unifi](https://hub.docker.com/r/jacobalberty/unifi) - Legacy UniFi Controller in Docker (supports ARM)

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Raspberry Pi (Raspbian)                   │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                  Docker Runtime                        │  │
│  │  ┌─────────────────────────────────────────────────┐  │  │
│  │  │           unifi-os-server container             │  │  │
│  │  │  ┌───────────────────────────────────────────┐  │  │  │
│  │  │  │    systemd (PID 1)                        │  │  │  │
│  │  │  │  ├── nginx (UniFi OS GUI :443)            │  │  │  │
│  │  │  │  ├── unifi-core (device management)       │  │  │  │
│  │  │  │  ├── mongodb (data store)                 │  │  │  │
│  │  │  │  ├── rabbitmq (message queue)             │  │  │  │
│  │  │  │  └── unifi-identity (authentication)      │  │  │  │
│  │  │  └───────────────────────────────────────────┘  │  │  │
│  │  └─────────────────────────────────────────────────┘  │  │
│  │                                                         │  │
│  │  ┌─────────────────────────────────────────────────┐   │  │
│  │  │     Network Services (host)                     │   │  │
│  │  │  ├── Port 11443 → container 443                │   │  │
│  │  │  ├── Port 8080  → container 8080               │   │  │
│  │  │  └── Port 3478  → container 3478 (UDP)         │   │  │
│  │  └─────────────────────────────────────────────────┘   │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐  │
│  │         Persistent Volumes (on Raspbian)               │  │
│  │  ├── /opt/unifi-os/data         (config)              │  │
│  │  ├── /opt/unifi-os/logs         (logs)                │  │
│  │  ├── /opt/unifi-os/certs        (SSL certificates)    │  │
│  │  └── /opt/unifi-os/var-lib      (MongoDB, UniFi data) │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Implementation Plan

### Phase 1: Repository Setup

**File Structure:**
```
unifi-os-rpi/
├── README.md                    # Project documentation
├── CLAUDE.md                    # AI context (this file)
├── docker-compose.yaml          # Main deployment config
├── Dockerfile.arm64            # ARM64 build (if custom image needed)
├── .env.example                # Environment template
├── scripts/
│   ├── install.sh              # Raspbian prerequisites setup
│   ├── backup.sh               # Backup configuration
│   └── restore.sh              # Restore configuration
└── docs/
    ├── setup.md                # Detailed setup guide
    ├── migration.md            # Migration from legacy UniFi
    └── troubleshooting.md      # Common issues
```

### Phase 2: Docker Compose Configuration

**Image:** `ghcr.io/lemker/unifi-os-server:5.0.6-linux-arm64`

**Critical container options (required for systemd):**
```yaml
privileged: true        # Required for systemd cgroup access
cgroupns: host          # Share host cgroup namespace
sysctls:
  - net.ipv4.ip_unprivileged_port_start=0  # Allow low ports
cap_add:
  - SYS_ADMIN        # Required for systemd
volumes:
  - /sys/fs/cgroup:/sys/fs/cgroup:ro  # cgroup access
```

**Key decisions:**
1. Use existing ARM64 image (no custom Dockerfile needed)
2. Configure required ports for device adoption
3. Set up persistent volumes on host

**Required Ports:**
| Port | Protocol | Purpose | Required |
|------|----------|---------|----------|
| 11443 | TCP | UniFi OS GUI/API | Yes |
| 8080 | TCP | Device command/control | Yes |
| 8443 | TCP | Legacy web interface | Optional |
| 3478 | UDP | STUN for adoption | Yes |
| 10003 | UDP | Device discovery | Yes |

**Optional Ports:**
| Port | Protocol | Purpose |
|------|----------|---------|
| 5005 | TCP | RTP control |
| 6789 | TCP | Speed test |
| 8843 | TCP | Hotspot portal |
| 8880-8882 | TCP | Portal redirect |

### Phase 3: Raspbian Prerequisites Script

**Critical Tasks:**
1. **Install Docker Engine** (not Docker Desktop):
   ```bash
   curl -fsSL https://get.docker.com | sh
   ```
2. **Enable Docker on boot:** `sudo systemctl enable docker`
3. **Add user to docker group:** `sudo usermod -aG docker $USER`
4. **Reboot** (required for cgroup functionality)
5. **Firewall:** Docker bypasses ufw, use iptables or configure Docker daemon

**Raspbian 64-bit strongly recommended:**
- Docker Engine v28+ no longer supports 32-bit (armhf)
- Use Raspberry Pi OS 64-bit (Bookworm)

### Phase 4: Environment Configuration

**Environment variables:**
- `UOS_SYSTEM_IP` - Hostname/IP for device adoption
- `TZ` - Timezone
- `PUID`/`PGID` - Run as non-root user
- `MEM_LIMIT` - JVM heap limit

### Phase 5: Backup & Restore

**Backup script should:**
1. Stop container gracefully
2. Archive `/opt/unifi-os/data` directory
3. Include timestamp in filename
4. Optional: Upload to remote storage (S3, etc.)

## Key Technical Considerations

### Why UniFi OS Server (not legacy UniFi Controller)

| Feature | UniFi OS Server | Legacy UniFi Controller |
|---------|-----------------|------------------------|
| Architecture | Full OS with systemd | Application only |
| Features | Organizations, IdP, SD-WAN | Basic network mgmt |
| Container | Privileged with systemd | Non-privileged |
| Base Image | ghcr.io/lemker/uosserver | Various |

## Raspberry Pi Specific Notes

1. **OS**: Raspberry Pi OS 64-bit (Bookworm) - Confirmed working
2. **Image**: `ghcr.io/lemker/unifi-os-server:5.0.6-linux-arm64`
3. **Memory**: 4GB+ RAM recommended
4. **Storage**: Use USB SSD for MongoDB data (SD cards will fail)
5. **Cooling**: Active cooling required for sustained operation

### Security Considerations

1. Run behind reverse proxy (nginx/Caddy) for TLS termination
2. Use fail2ban for brute-force protection
3. Regularly update base image for security patches
4. Consider network isolation for management interface

## Quick Start

```bash
# 1. Clone and enter repository
git clone https://github.com/yourusername/unifi-os-rpi.git
cd unifi-os-rpi

# 2. Install prerequisites
./scripts/install.sh

# 3. Configure environment
cp .env.example .env
# Edit .env with your settings

# 4. Start services
docker compose up -d

# 5. Access UniFi OS
# https://<UOS_SYSTEM_IP>:11443
```

## Migration from Legacy UniFi Controller

1. Backup existing UniFi Controller data
2. Stop legacy container
3. Copy data to new volume structure
4. Start new container
5. Re-adopt devices via `set-inform`

## Potential Issues & Mitigations

| Issue | Cause | Mitigation |
|-------|-------|------------|
| Container won't start | Missing cgroup access | Use `privileged: true` and `cgroupns: host` |
| Ports < 1024 fail | Low port restriction | Set `sysctl net.ipv4.ip_unprivileged_port_start=0` |
| Device adoption fails | Firewall blocking | Allow UDP 3478, TCP 8080 |
| MongoDB crashes | Memory pressure | Reduce JVM heap, add swap |
| 32-bit issues | MongoDB drop support | Use 64-bit OS |

## References

- [lemker/unifi-os-server](https://github.com/lemker/unifi-os-server)
- [jacobalberty/unifi Docker image](https://hub.docker.com/r/jacobalberty/unifi)
- [UniFi OS Documentation](https://help.ui.com)
