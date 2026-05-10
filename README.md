# Custom Debian-based ISO Builder

[![CI build](https://github.com/aitorpazos/create-debian-iso/actions/workflows/ci.yml/badge.svg)](https://github.com/aitorpazos/create-debian-iso/actions/workflows/ci.yml)

Docker-based tool to build custom live ISOs for Debian-based distributions. Mount a config directory, run the container, and get a bootable ISO.

Based on [Will Haley's guide](https://willhaley.com/blog/custom-debian-live-environment/).

## Supported distributions

| Distribution | Tag | Base |
|---|---|---|
| Debian Bookworm | `debian-bookworm` | `debian:bookworm` |
| Ubuntu Noble (24.04) | `ubuntu-noble` | `ubuntu:noble` |
| KDE Neon | `kde-neon` | `ubuntu:noble` + Neon repos |

## Quick start

```bash
docker run -t --rm --privileged \
  -e OUTPUT_FILE=my-custom.iso \
  -v $(pwd)/my-config:/root/files \
  aitorpazos/create-debian-iso:debian-bookworm
```

The output ISO will appear in `$(pwd)/my-config/`.

## Configuration

Create a directory with a `config/` subdirectory containing:

| File | Required | Description |
|---|---|---|
| `config/configure.sh` | ✅ | Custom configuration script run inside the chroot |
| `config/packages` | ✅ | Packages to install (one per line or space-separated) |
| `config/repositories` | ✅ | Additional APT repositories (`sources.list` format) |
| `config/repositories-keys` | ✅ | URLs to GPG keys for additional repositories (one per line) |

All files in `config/` are copied to `/root/` inside the chroot, so `configure.sh` can access them.

### Example structure

```
my-config/
└── config/
    ├── configure.sh          # Custom setup script
    ├── packages              # e.g. "vim curl htop"
    ├── repositories          # Additional APT repos
    └── repositories-keys     # GPG key URLs
```

See the [`example/`](example/) directory for a minimal working configuration.

## Environment variables

| Variable | Default | Description |
|---|---|---|
| `OUTPUT_FILE` | `<distro>-<flavor>-custom.iso` | Output ISO filename |
| `ROOT_PASSWD` | `toor` | Root password for the live system |

## Building from source

```bash
# Build all variants
make build

# Build specific variant
make buildDebianBookworm
make buildUbuntuNoble
make buildKdeNeon

# Run tests (builds example ISOs)
make test

# Lint shell scripts
make lint
```

## Repository keys migration (v0.x → v1.0)

In v1.0, the `repositories-keys` file format changed from keyserver-based (`<keyserver> <key-id>`) to URL-based (one GPG key URL per line). This uses the modern `signed-by` approach instead of the deprecated `apt-key`.

**Before (v0.x):**
```
hkp://keyserver.ubuntu.com:80 9DA31620334BD75D9DCB49F368818C72E52529D4
```

**After (v1.0):**
```
https://www.mongodb.org/static/pgp/server-7.0.asc
```

## License

GPLv3
