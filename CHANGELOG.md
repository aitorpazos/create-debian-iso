# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Debian `buster` replaced by `bullseye`.

## [0.4.0] - 2021-09-19

### Added

- Support for Kde Neon (Based on Ubuntu)
 
## [0.3.4] - 2021-09-19

### Fixed

- Make `/proc` available in chroot environment as it is needed by some packages install (eg: java)
 
## [0.3.3] - 2021-09-19

### Fixed

- Fix reposiotries configuration for Ubuntu
 
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
