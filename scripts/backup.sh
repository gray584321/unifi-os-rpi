#!/bin/bash
set -e

# Load configuration
DATA_DIR="${DATA_DIR:-/opt/unifi-os}"
BACKUP_DIR="${BACKUP_DIR:-/opt/unifi-os/backups}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="unifi-os-backup_${TIMESTAMP}"
CONTAINER_NAME="unifi-os-server"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}UniFi OS Server Backup${NC}"
echo "Timestamp: $TIMESTAMP"
echo ""

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Check if container is running
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "${RED}Error: Container '$CONTAINER_NAME' is not running${NC}"
    exit 1
fi

echo -e "${GREEN}[1/4]${NC} Stopping UniFi OS Server..."
docker stop "$CONTAINER_NAME"

echo -e "${GREEN}[2/4]${NC} Creating backup archive..."
BACKUP_PATH="${BACKUP_DIR}/${BACKUP_NAME}.tar.gz"
tar -czf "$BACKUP_PATH" -C "$(dirname "$DATA_DIR")" "$(basename "$DATA_DIR")"

echo -e "${GREEN}[3/4]${NC} Restarting UniFi OS Server..."
docker start "$CONTAINER_NAME"

echo -e "${GREEN}[4/4]${NC} Verifying backup..."
if [[ -f "$BACKUP_PATH" ]]; then
    SIZE=$(du -h "$BACKUP_PATH" | cut -f1)
    echo -e "${GREEN}Backup created successfully!${NC}"
    echo "  Location: $BACKUP_PATH"
    echo "  Size: $SIZE"
else
    echo -e "${RED}Error: Backup file not found${NC}"
    exit 1
fi

# Cleanup old backups (keep last 7)
echo ""
echo "Cleaning up old backups..."
find "$BACKUP_DIR" -name "unifi-os-backup_*.tar.gz" -type f -mtime +7 -delete
echo "Done"

echo ""
echo -e "${GREEN}Backup complete!${NC}"
