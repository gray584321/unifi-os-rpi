#!/bin/bash
# =============================================================================
# UniFi OS Server - Custom Entrypoint
# =============================================================================
# Purpose: Apply custom configuration before starting systemd
# =============================================================================

set -euo pipefail

echo "[unifi-os-rpi] Starting UniFi OS Server..."

# Apply any custom configuration here
# - Environment variable validation
# - Permission fixes
# - Custom certificate handling

exec /init.sh "$@"
