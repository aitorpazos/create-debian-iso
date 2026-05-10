#!/bin/bash
set -euo pipefail

ROOT_PASSWD="${1:?Root password required}"

# Set hostname
echo "live-iso" > /etc/hostname

# Set noninteractive APT frontend
export DEBIAN_FRONTEND=noninteractive

# Import repository GPG keys using modern signed-by approach
KEYRING_DIR="/usr/share/keyrings"
mkdir -p "${KEYRING_DIR}"

while IFS= read -r line || [ -n "${line}" ]; do
  # Skip comments and empty lines
  if echo "${line}" | grep -qE '^\s*#|^\s*$'; then
    continue
  fi
  KEY_URL="${line}"
  KEY_NAME="${KEY_URL//[^a-zA-Z0-9]/-}"
  echo "Importing key from: ${KEY_URL}"
  wget -qO - "${KEY_URL}" | gpg --dearmor -o "${KEYRING_DIR}/${KEY_NAME}.gpg" || \
    echo "Warning: Failed to import key from ${KEY_URL}"
done < /root/repositories-keys

# Install base dependencies
# Linux image names are named differently in different distros
# shellcheck source=/dev/null
. /etc/os-release
DPKG_ARCH="$(dpkg --print-architecture)"
LINUX_PACKAGE=linux-image-generic
if [ "${ID}" = "debian" ]; then
  if [ "${DPKG_ARCH}" = "arm64" ]; then
    LINUX_PACKAGE=linux-image-arm64
  else
    LINUX_PACKAGE=linux-image-amd64
  fi
fi

echo "Setting default repositories configuration..."
if [ "${ID}" = "ubuntu" ]; then
  cat << EOF > /etc/apt/sources.list
# See http://help.ubuntu.com/community/UpgradeNotes for how to upgrade to
# newer versions of the distribution.
deb http://archive.ubuntu.com/ubuntu/ ${DISTRO_VERSION} main restricted
deb http://archive.ubuntu.com/ubuntu/ ${DISTRO_VERSION}-updates main restricted
deb http://archive.ubuntu.com/ubuntu/ ${DISTRO_VERSION} universe
deb http://archive.ubuntu.com/ubuntu/ ${DISTRO_VERSION}-updates universe
deb http://archive.ubuntu.com/ubuntu/ ${DISTRO_VERSION} multiverse
deb http://archive.ubuntu.com/ubuntu/ ${DISTRO_VERSION}-updates multiverse
deb http://archive.ubuntu.com/ubuntu/ ${DISTRO_VERSION}-backports main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu/ ${DISTRO_VERSION}-security main restricted
deb http://security.ubuntu.com/ubuntu/ ${DISTRO_VERSION}-security universe
deb http://security.ubuntu.com/ubuntu/ ${DISTRO_VERSION}-security multiverse
EOF
fi

# Update APT repos
apt-get update

apt-get install -y --no-install-recommends \
    "${LINUX_PACKAGE}" \
    live-boot \
    gnupg2 \
    wget \
    systemd-sysv

# Add support for KDE Neon
if [ "${DISTRO_FLAVOR:-}" = "neon" ]; then
  # Import KDE Neon key using modern approach
  wget -qO - 'https://archive.neon.kde.org/public.key' | \
    gpg --dearmor -o "${KEYRING_DIR}/kde-neon.gpg"

  cat <<EOF > /etc/apt/sources.list.d/neon.list
deb [signed-by=${KEYRING_DIR}/kde-neon.gpg] http://archive.neon.kde.org/user/ ${DISTRO_VERSION} main
deb-src [signed-by=${KEYRING_DIR}/kde-neon.gpg] http://archive.neon.kde.org/user/ ${DISTRO_VERSION} main
EOF

  # Pin base-files to not install the Neon version
  # This prevents the install identifying as Neon,
  # and stops problems with programs that this confuses,
  # e.g. the Docker install script
  cat <<EOF > /etc/apt/preferences.d/99block-neon
Package: base-files
Pin: origin archive.neon.kde.org
Pin-Priority: 1
EOF

  apt-get update
  apt-get upgrade -y
fi

# Install additional packages (word splitting is intentional here)
# shellcheck disable=SC2046
apt-get install -y --no-install-recommends $(cat /root/packages)

# Clean cached files
apt-get clean -y

# Set root password
echo "root:${ROOT_PASSWD}" | chpasswd

# Run extra configuration script
echo "Launching configure.sh script"
exec /root/configure.sh
