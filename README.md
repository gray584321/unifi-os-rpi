# UniFi OS Server on Raspberry Pi

Deploy **UniFi OS Server** on a Raspberry Pi running Raspbian 64-bit using Docker.

This repository provides a complete setup with Docker Compose, installation scripts, and backup utilities for running Ubiquiti's UniFi OS platform on Raspberry Pi hardware.

## Features

- Full UniFi OS Server with systemd inside container
- Pre-configured Docker Compose for ARM64
- Automated installation script
- Backup and restore utilities
- Persistent storage for config, logs, and MongoDB

## Requirements

| Requirement | Minimum | Recommended |
|-------------|---------|-------------|
| Raspberry Pi | Pi 4 | Pi 4 (4GB+) or Pi 5 |
| OS | Raspberry Pi OS 64-bit (Bookworm) | Raspberry Pi OS 64-bit |
| RAM | 2GB | 4GB+ |
| Storage | USB SSD | USB 3.0 SSD |
| Docker | Docker Engine 20.10+ | Latest |

**Important:** Docker Engine v28+ no longer supports 32-bit (armhf). You must use **64-bit Raspbian**.

Verify your OS:
```bash
uname -m  # Should return aarch64
```

## Quick Start

### 1. Clone and Configure

```bash
git clone https://github.com/yourusername/unifi-os-rpi.git
cd unifi-os-rpi

# Copy environment template
cp .env.example .env

# Edit with your settings
nano .env
```

Required setting in `.env`:
```bash
UOS_SYSTEM_IP=unifi.yourdomain.com  # Your Pi's IP or hostname
```

### 2. Run Installation Script

```bash
# Make executable
chmod +x scripts/install.sh

# Run as root
sudo ./scripts/install.sh

# Reboot (recommended)
sudo reboot
```

### 3. Start UniFi OS

```bash
# Start the container
docker compose up -d

# Check status
docker ps

# View logs
docker logs -f unifi-os-server
```

### 4. Access UniFi OS

Open your browser to: `https://<UOS_SYSTEM_IP>:11443`

First-time setup will create your UniFi OS admin account.

## Port Reference

| Port | Protocol | Service | Required |
|------|----------|---------|----------|
| 11443 | TCP | UniFi OS GUI/API | Yes |
| 8080 | TCP | Device command/control | Yes |
| 8443 | TCP | Legacy web interface | Optional |
| 3478 | UDP | STUN for adoption | Yes |
| 10001 | UDP | Device discovery | Yes |
| 5005 | TCP | RTP control | Optional |
| 6789 | TCP | Speed test | Optional |
| 8843 | TCP | Hotspot portal | Optional |
| 8880-8882 | TCP | Portal redirect | Optional |

## Directory Structure

```
/opt/unifi-os/
├── data/           # UniFi OS configuration
├── logs/           # Application logs
├── certs/          # SSL certificates
├── var-lib-unifi/  # UniFi application data
├── var-lib-mongodb/# MongoDB database
└── backups/        # Backup storage
```

## Management Commands

```bash
# Start/Stop/Restart
docker compose up -d
docker compose stop
docker compose restart

# View logs
docker logs unifi-os-server
docker logs -f unifi-os-server  # Follow

# Update container
docker compose pull
docker compose up -d

# Check resource usage
docker stats unifi-os-server
```

## Backup and Restore

### Create Backup

```bash
# Create timestamped backup
./scripts/backup.sh

# Backups are stored in /opt/unifi-os/backups/
```

### Restore from Backup

```bash
# List available backups
ls /opt/unifi-os/backups/

# Restore specific backup
sudo ./scripts/restore.sh /opt/unifi-os/backups/unifi-os-backup_20240101_120000.tar.gz
```

## Device Adoption

After setup, adopt your UniFi devices by SSHing to each device and running:

```bash
# For UniFi devices
set-inform http://<UOS_SYSTEM_IP>:8080/inform

# Force adoption (if needed)
set-inform http://<UOS_SYSTEM_IP>:8080/inform forced
```

## Migration from Legacy UniFi Controller

If migrating from `jacobalberty/unifi` or another setup:

1. Backup existing controller data
2. Copy data to new location:
   ```bash
   # Stop old container
   docker stop unifi

   # Copy data (adjust paths as needed)
   sudo cp -r /path/to/old/data/* /opt/unifi-os/data/
   sudo cp -r /path/to/old/var-lib-unifi/* /opt/unifi-os/var-lib-unifi/
   ```

3. Start new container
4. Re-adopt devices via `set-inform`

## Troubleshooting

### Container Won't Start

Check if cgroup is properly configured:
```bash
docker logs unifi-os-server
```

Ensure you rebooted after Docker installation.

### Device Adoption Fails

1. Verify firewall allows TCP 8080 and UDP 3478
2. Check `UOS_SYSTEM_IP` is accessible from devices
3. Verify devices can reach the Pi on those ports

### MongoDB Crashes (Out of Memory)

Add swap space:
```bash
sudo dphys-swapfile setup
sudo dphys-swapfile swapon
```

Or reduce JVM heap in `.env`:
```bash
JVM_MAX_HEAP_SIZE=512m
```

### Container Uses Too Much Memory

```bash
# Check memory usage
docker stats unifi-os-server

# Add swap (2GB recommended on Pi)
sudo apt install dphys-swapfile
```

## Security Recommendations

1. **Use TLS termination**: Run behind nginx/Caddy with Let's Encrypt
2. **Firewall**: Only expose ports 11443 and 8080 externally
3. **Updates**: Regularly pull latest image: `docker compose pull`
4. **Backups**: Schedule regular backups via cron

Example cron for nightly backup:
```bash
0 3 * * * /opt/unifi-os-rpi/scripts/backup.sh >> /var/log/unifi-backup.log 2>&1
```

## Credits

- [lemker/unifi-os-server](https://github.com/lemker/unifi-os-server) - Base Docker image
- [jacobalberty/unifi](https://hub.docker.com/r/jacobalberty/unifi) - Legacy UniFi Controller

## License

MIT License
