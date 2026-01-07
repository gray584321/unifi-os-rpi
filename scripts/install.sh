#!/bin/bash
# =============================================================================
# UniFi OS Server - Installation Script
# =============================================================================
# Purpose: Install Docker and configure UniFi OS Server on Raspberry Pi
# =============================================================================

set -euo pipefail

readonly SCRIPT_VERSION="1.0.0"
readonly DOCKER_BASE_URL="https://get.docker.com"

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }
log_step() { echo -e "${BLUE}[STEP]${NC} $*"; }

main() {
    local data_dir="${DATA_DIR:-/opt/unifi-os}"
    local version="${UNIFI_OS_VERSION:-5.0.6}"

    echo "============================================"
    echo "  UniFi OS Server - Installation Script"
    echo "  Version: ${SCRIPT_VERSION}"
    echo "============================================"
    echo ""

    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root (use sudo)"
        exit 1
    fi

    check_architecture
    check_raspberry_pi
    install_docker
    enable_docker_service
    add_user_to_docker
    install_docker_compose
    create_directory_structure "$data_dir"
    pull_image "$version"

    echo ""
    echo "============================================"
    log_info "Installation Complete!"
    echo "============================================"
    echo ""
    echo "Next steps:"
    echo "1. Edit .env with your configuration: cp .env.example .env && nano .env"
    echo "2. Start UniFi OS: docker compose up -d"
    echo "3. Access at: https://<UOS_SYSTEM_IP>:11443"
    echo ""
    echo "Reboot recommended for cgroup functionality:"
    echo "  sudo reboot"
}

check_architecture() {
    local arch
    arch=$(uname -m)
    if [[ "$arch" != "aarch64" ]]; then
        log_error "This requires a 64-bit OS. Current architecture: $arch"
        log_error "Please install Raspberry Pi OS 64-bit"
        exit 1
    fi
    log_info "Architecture check passed: $arch"
}

check_raspberry_pi() {
    if grep -q "Raspberry Pi" /proc/cpuinfo 2>/dev/null; then
        log_info "Raspberry Pi detected"
    else
        log_warn "This does not appear to be a Raspberry Pi"
        log_warn "Continuing anyway..."
    fi
}

install_docker() {
    if command -v docker &> /dev/null; then
        log_info "Docker is already installed"
        docker --version
        return 0
    fi
    log_info "Installing Docker Engine..."
    curl -fsSL "$DOCKER_BASE_URL" | sh
    log_info "Docker installed successfully"
}

enable_docker_service() {
    log_info "Enabling Docker service on boot..."
    systemctl enable docker
    systemctl start docker
    log_info "Docker service enabled and started"
}

add_user_to_docker() {
    if [[ -n "${SUDO_USER:-}" ]] && id "$SUDO_USER" &>/dev/null; then
        usermod -aG docker "$SUDO_USER"
        log_info "User '$SUDO_USER' added to docker group"
    fi
}

install_docker_compose() {
    if command -v docker compose &> /dev/null; then
        log_info "docker-compose is already installed"
        return 0
    fi
    log_info "Installing docker-compose..."
    apt-get update -qq
    apt-get install -y -qq docker-compose-plugin
    log_info "docker-compose installed"
}

create_directory_structure() {
    log_info "Creating directory structure..."
    mkdir -p "$1"/{data,logs,certs,var-lib-unifi,var-lib-mongodb}
    chmod 755 "$1" -R
    log_info "Created $1"
}

pull_image() {
    local image="ghcr.io/lemker/unifi-os-server:${1}-linux-arm64"
    log_info "Pulling image: $image"
    docker pull "$image"
}

main "$@"
