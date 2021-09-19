#!/bin/bash

export ROOT_PASSWD=$1

# Set hostname
echo "live-iso" > /etc/hostname

# Set noninteractive APT frontend
export DEBIAN_FRONTEND=noninteractive

# Add support function
function addRepo() {
  KEYSERVER=$1
  KEY=$2
  apt-key adv --keyserver ${KEYSERVER} --recv ${KEY}
}

# Process repositories
for line in "$(cat /root/repositories-keys)"; do
  if echo "${line}" | egrep -v '^#'; then
    addRepo ${line}
  fi;
done;

# Install base dependencies
# Linux image names (eg: linux-image-amd64 or linux-image) are named differently in different distros and we need to 
# check that
. /etc/os-release
LINUX_PACKAGE=linux-image-generic
if [ "${ID}" == "debian" ]; then
  LINUX_PACKAGE=linux-image-amd64 
fi

echo "Setting default repositories configuration..."
if [ "${ID}" == "ubuntu" ]; then
  cat << EOF > /etc/apt/sources.list
# See http://help.ubuntu.com/community/UpgradeNotes for how to upgrade to
# newer versions of the distribution.
deb http://archive.ubuntu.com/ubuntu/ ${DISTRO_VERSION} main restricted
# deb-src http://archive.ubuntu.com/ubuntu/ ${DISTRO_VERSION} main restricted

## Major bug fix updates produced after the final release of the
## distribution.
deb http://archive.ubuntu.com/ubuntu/ ${DISTRO_VERSION}-updates main restricted
# deb-src http://archive.ubuntu.com/ubuntu/ ${DISTRO_VERSION}-updates main restricted

## N.B. software from this repository is ENTIRELY UNSUPPORTED by the Ubuntu
## team. Also, please note that software in universe WILL NOT receive any
## review or updates from the Ubuntu security team.
deb http://archive.ubuntu.com/ubuntu/ ${DISTRO_VERSION} universe
# deb-src http://archive.ubuntu.com/ubuntu/ ${DISTRO_VERSION} universe
deb http://archive.ubuntu.com/ubuntu/ ${DISTRO_VERSION}-updates universe
# deb-src http://archive.ubuntu.com/ubuntu/ ${DISTRO_VERSION}-updates universe

## N.B. software from this repository is ENTIRELY UNSUPPORTED by the Ubuntu
## team, and may not be under a free licence. Please satisfy yourself as to
## your rights to use the software. Also, please note that software in
## multiverse WILL NOT receive any review or updates from the Ubuntu
## security team.
deb http://archive.ubuntu.com/ubuntu/ ${DISTRO_VERSION} multiverse
# deb-src http://archive.ubuntu.com/ubuntu/ ${DISTRO_VERSION} multiverse
deb http://archive.ubuntu.com/ubuntu/ ${DISTRO_VERSION}-updates multiverse
# deb-src http://archive.ubuntu.com/ubuntu/ ${DISTRO_VERSION}-updates multiverse

## N.B. software from this repository may not have been tested as
## extensively as that contained in the main release, although it includes
## newer versions of some applications which may provide useful features.
## Also, please note that software in backports WILL NOT receive any review
## or updates from the Ubuntu security team.
deb http://archive.ubuntu.com/ubuntu/ ${DISTRO_VERSION}-backports main restricted universe multiverse
# deb-src http://archive.ubuntu.com/ubuntu/ ${DISTRO_VERSION}-backports main restricted universe multiverse

## Uncomment the following two lines to add software from Canonical's
## 'partner' repository.
## This software is not part of Ubuntu, but is offered by Canonical and the
## respective vendors as a service to Ubuntu users.
# deb http://archive.canonical.com/ubuntu ${DISTRO_VERSION} partner
# deb-src http://archive.canonical.com/ubuntu ${DISTRO_VERSION} partner

deb http://security.ubuntu.com/ubuntu/ ${DISTRO_VERSION}-security main restricted
# deb-src http://security.ubuntu.com/ubuntu/ ${DISTRO_VERSION}-security main restricted
deb http://security.ubuntu.com/ubuntu/ ${DISTRO_VERSION}-security universe
# deb-src http://security.ubuntu.com/ubuntu/ ${DISTRO_VERSION}-security universe
deb http://security.ubuntu.com/ubuntu/ ${DISTRO_VERSION}-security multiverse
# deb-src http://security.ubuntu.com/ubuntu/ ${DISTRO_VERSION}-security multiverse
EOF
fi

# Add support for KDE Neon
if [ "${DISTRO_FLAVOR}" == "neon" ]; then
  # add the KDE Neon repository
  wget -qO - 'https://archive.neon.kde.org/public.key' | sudo apt-key add -
  
  cat <<EOF > /etc/apt/sources.list.d/neon.list
  deb http://archive.neon.kde.org/user/ ${DISTRO_VERSION} main
  deb-src http://archive.neon.kde.org/user/ ${DISTRO_VERSION} main
EOF
  
  # pin base-files to not install the Neon version
  # - this prevents the install identifying as Neon,
  # and stops problems with programs that this confuses,
  # eg the Docker install script 
  cat <<EOF > /etc/apt/preferences.d/99block-neon 
  Package: base-files
  Pin: origin archive.neon.kde.org
  Pin-Priority: 1  
EOF
fi
 
# Update ATP repos
apt-get update

apt-get install -y --no-install-recommends \
    ${LINUX_PACKAGE} \
    live-boot \
    systemd-sysv

# Install additional packages
apt-get install -y --no-install-recommends $(cat /root/packages)

# Clean cached files
apt-get clean -y

# Set root password
passwd root << EOF
${ROOT_PASSWD}
${ROOT_PASSWD}
EOF

# Run extra configuration script
echo "Launching conifgure.sh script"
exec /root/configure.sh
