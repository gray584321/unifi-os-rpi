#!/bin/bash
set -e

# Load configuration
DATA_DIR="${DATA_DIR:-/opt/unifi-os}"
BACKUP_DIR="${BACKUP_DIR:-/opt/unifi-os/backups}"
CONTAINER_NAME="unifi-os-server"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}UniFi OS Server Restore${NC}"
echo ""

# Check for backup file argument
if [[ -z "$1" ]]; then
    echo "Usage: $0 <backup_file.tar.gz>"
    echo ""
    echo "Available backups:"
    ls -la "$BACKUP_DIR"/*.tar.gz 2>/dev/null || echo "  No backups found in $BACKUP_DIR"
    exit 1
fi

BACKUP_FILE="$1"

# Check if backup file exists
if [[ ! -f "$BACKUP_FILE" ]]; then
    echo -e "${RED}Error: Backup file not found: $BACKUP_FILE${NC}"
    exit 1
fi

echo -e "${YELLOW}[1/5]${NC} Stopping UniFi OS Server..."
docker stop "$CONTAINER_NAME" 2>/dev/null || true

echo -e "${YELLOW}[2/5]${NC} Backing up current data (if exists)..."
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
if [[ -d "$DATA_DIR" ]]; then
    CURRENT_BACKUP="${BACKUP_DIR}/pre-restore_${TIMESTAMP}.tar.gz"
    tar -czf "$CURRENT_BACKUP" -C "$(dirname "$DATA_DIR")" "$(basename "$DATA_DIR")"
    echo "  Current data backed up to: $CURRENT_BACKUP"
fi

echo -e "${YELLOW}[3/5]${NC} Removing current data..."
rm -rf "$DATA_DIR"/*

echo -e "${YELLOW}[4/5]${NC} Restoring from backup..."
tar -xzf "$BACKUP_FILE" -C "$(dirname "$DATA_DIR")"

echo -e "${YELLOW}[5/5]${NC} Starting UniFi OS Server..."
docker start "$CONTAINER_NAME"

echo ""
echo -e "${GREEN}Restore complete!${NC}"
echo ""
echo -e "${YELLOW}Important:${NC}"
echo "- If this was a migration, you may need to re-adopt devices"
echo "- Check logs if issues occur: docker logs $CONTAINER_NAME"
echo ""
echo "To monitor startup:"
echo "  docker logs -f $CONTAINER_NAME"
