# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-05-11

### Changed

- Debian `bullseye` replaced by `bookworm`.
- Ubuntu `jammy` replaced by `noble` (24.04 LTS).
- Repository keys now use URL-based GPG import with `signed-by` instead of deprecated `apt-key`.
- Debian mirror updated from `ftp.us.debian.org` to `deb.debian.org`.
- Root password is now set via `chpasswd` instead of piping to `passwd`.
- All shell scripts use `set -euo pipefail` and proper quoting.
- CI updated to `actions/checkout@v4` with parallel jobs and shellcheck linting.
- Release workflow updated to `docker/login-action@v3` and `softprops/action-gh-release@v2`.

### Added

- `ARCH` build argument for architecture selection (defaults to `amd64`).
- `grub-efi-arm64-bin` package installed when building for arm64.
- Shellcheck linting in CI and via `make lint`.
- `.dockerignore` updated to exclude `.github` and `.git` directories.

### Removed

- Deprecated `apt-key` usage.
- Deprecated `actions/create-release@v1` and `actions/upload-release-asset@v1`.
- Deprecated `egrep` usage (replaced with `grep -E`).
- Deprecated `set-output` GitHub Actions syntax.

## [0.5.0] - 2022-07-23

### Changed

- Debian `buster` replaced by `bullseye`.
- Ubuntu `focal` replaced by `jammy`.

### Removed

- Ubuntu `bionic`

## [0.4.0] - 2021-09-19

### Added

- Support for Kde Neon (Based on Ubuntu)

## [0.3.4] - 2021-09-19

### Fixed

- Make `/proc` available in chroot environment as it is needed by some packages install (eg: java)

## [0.3.3] - 2021-09-19

### Fixed

- Fix repositories configuration for Ubuntu

## [0.3.2] - 2021-09-07

### Fixed

- Add missing `DISTRO` env value

## [0.3.1] - 2021-09-06

### Fixed

- Release workflow

## [0.3.0] - 2021-09-06

### Added

- Support for Ubuntu based ISOs
- Support to customise output ISO file specifying the `OUTPUT_FILE`

## [0.2.0] - 2021-02-20

### Changed

- The volume mounted in the docker run is now expected to contain a `config` directory with the config files.
- Now all files in `config` directory are available in chroot environment to `configure.sh` script in `/root`

## [0.1.0] - 2021-02-14

### Added

- Initial release
