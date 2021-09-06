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

# Update ATP repos
apt-cache update

# Install base dependencies
apt-get install -y --no-install-recommends \
    linux-image-amd64 \
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
/root/configure.sh
