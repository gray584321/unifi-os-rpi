# syntax=docker/dockerfile:1.4
# =============================================================================
# UniFi OS Server - Multi-Architecture Docker Image
# =============================================================================
# Supports: linux/arm64, linux/amd64
# Base: ghcr.io/lemker/unifi-os-server
# =============================================================================

ARG BASE_IMAGE_TAG=5.0.6

FROM --platform=$BUILDPLATFORM ghcr.io/lemker/unifi-os-server:${BASE_IMAGE_TAG}-linux-arm64 AS builder

LABEL org.opencontainers.image.title="UniFi OS Server" \
      org.opencontainers.image.description="UniFi OS Server for Raspberry Pi and x86_64" \
      org.opencontainers.image.version="${BASE_IMAGE_TAG}" \
      org.opencontainers.image.source="https://github.com/unifi-os-rpi/unifi-os-server" \
      org.opencontainers.image.vendor="UniFi OS RPi Contributors" \
      org.opencontainers.image.license="MIT" \
      org.opencontainers.image.platforms="linux/arm64,linux/amd64" \
      maintainer="UniFi OS RPi Contributors"

FROM ghcr.io/lemker/unifi-os-server:${BASE_IMAGE_TAG}-linux-${TARGETARCH}

COPY docker/entrypoint.sh /entrypoint-custom.sh

ENTRYPOINT ["/bin/bash", "/entrypoint-custom.sh"]
