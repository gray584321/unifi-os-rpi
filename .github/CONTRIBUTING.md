# Contributing to UniFi OS RPi

Thank you for your interest in contributing to UniFi OS RPi!

## Prerequisites

Before contributing, ensure you have the following tools installed:

- Git
- Docker (for testing changes)
- ShellCheck (for script linting)
- Hadolint (for Dockerfile linting)

## Development Setup

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/unifi-os-rpi.git
   cd unifi-os-rpi
   ```
3. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Code Style Guidelines

### Shell Scripts

- Use `set -euo pipefail` at the top of all scripts
- Use `readonly` for constants
- Use meaningful variable names
- Add comments for complex logic
- All scripts must pass ShellCheck with no errors

### Dockerfiles

- Follow Hadolint recommendations
- Use specific version tags for base images (not `latest`)
- Add appropriate LABEL metadata
- Minimize layer count where possible

## Testing

Before submitting a pull request, verify your changes:

```bash
# Validate YAML files
docker compose -f docker-compose.yaml config

# Lint shell scripts
shellcheck scripts/*.sh

# Lint Dockerfile
hadolint docker/Dockerfile
```

## Pull Request Process

1. Ensure all tests and linting checks pass
2. Update documentation as needed
3. Add clear commit messages
4. Request review from maintainers
5. Address any feedback and squash commits if requested

## Reporting Issues

When reporting bugs, include:

- Clear description of the problem
- Steps to reproduce
- Expected vs actual behavior
- Relevant logs and environment details
