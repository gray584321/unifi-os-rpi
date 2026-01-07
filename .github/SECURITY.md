# Security Policy

## Supported Versions

The following versions are currently supported with security updates:

| Version | Supported |
|---------|-----------|
| Latest 5.x | Yes |
| Previous 5.x | Yes |
| Older versions | No |

## Reporting a Vulnerability

We take security seriously. If you believe you have found a security vulnerability, please report it responsibly.

### How to Report

1. Email your report to: security@unifi-os-rpi.example.com
2. Include in your report:
   - Detailed description of the vulnerability
   - Steps to reproduce the issue
   - Potential impact assessment
   - Any suggested mitigations (if applicable)

### Response Timeline

- **Acknowledgment**: Within 24 hours of receiving your report
- **Initial Assessment**: Within 72 hours
- **Fix Development**: Based on severity, typically 1-2 weeks
- **Notification**: You will be notified when a fix is released

## Security Best Practices

When deploying UniFi OS RPi, consider:

- Use TLS termination at your reverse proxy
- Keep Docker images up to date
- Use strong credentials for the UniFi OS admin account
- Restrict network access to management ports
- Regularly backup your configuration
