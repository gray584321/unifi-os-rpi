#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  UniFi OS Server - RPi Install Script${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root (use sudo)${NC}"
   exit 1
fi

# Check if running on Raspberry Pi
if ! grep -q "Raspberry Pi" /proc/cpuinfo 2>/dev/null; then
    echo -e "${YELLOW}Warning: This doesn't appear to be a Raspberry Pi${NC}"
    echo "Continuing anyway..."
fi

# Check if 64-bit OS
ARCH=$(uname -m)
if [[ "$ARCH" != "aarch64" ]]; then
    echo -e "${RED}Error: This requires a 64-bit OS. Current architecture: $ARCH${NC}"
    echo "Please install Raspberry Pi OS 64-bit"
    exit 1
fi

echo -e "${GREEN}[1/6]${NC} Checking existing Docker installation..."
if command -v docker &> /dev/null; then
    echo -e "${GREEN}  Docker is already installed${NC}"
    docker --version
else
    echo -e "${YELLOW}  Installing Docker Engine...${NC}"
    curl -fsSL https://get.docker.com | sh
    echo -e "${GREEN}  Docker installed successfully${NC}
fi

echo ""
echo -e "${GREEN}[2/6]${NC} Enabling Docker service on boot..."
systemctl enable docker
systemctl start docker

echo ""
echo -e "${GREEN}[3/6]${NC} Adding user to docker group..."
if id "$SUDO_USER" &>/dev/null; then
    usermod -aG docker "$SUDO_USER"
    echo -e "${GREEN}  User '$SUDO_USER' added to docker group${NC}"
else
    echo -e "${YELLOW}  Could not find SUDO_USER, skipping group addition${NC}"
fi

echo ""
echo -e "${GREEN}[4/6]${NC} Installing docker-compose..."
if ! command -v docker compose &> /dev/null; then
    apt-get update -qq
    apt-get install -y -qq docker-compose-plugin
    echo -e "${GREEN}  docker-compose installed${NC}"
else
    echo -e "${GREEN}  docker-compose is already installed${NC}"
fi

echo ""
echo -e "${GREEN}[5/6]${NC} Creating directory structure..."
# Read DATA_DIR from .env if it exists, otherwise use default
DATA_DIR="${DATA_DIR:-/opt/unifi-os}"
mkdir -p "$DATA_DIR"/{data,logs,certs,var-lib-unifi,var-lib-mongodb}
chmod 755 "$DATA_DIR" -R
echo -e "${GREEN}  Created $DATA_DIR${NC}"

echo ""
echo -e "${GREEN}[6/6]${NC} Pulling UniFi OS Server image..."
docker pull ghcr.io/lemker/unifi-os-server:5.0.6-linux-arm64

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  Installation Complete!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo "Next steps:"
echo "1. Edit .env with your configuration: cp .env.example .env && nano .env"
echo "2. Start UniFi OS: docker compose up -d"
echo "3. Access at: https://<UOS_SYSTEM_IP>:11443"
echo ""
echo -e "${YELLOW}Reboot recommended for cgroup functionality:${NC}"
echo "  sudo reboot"
