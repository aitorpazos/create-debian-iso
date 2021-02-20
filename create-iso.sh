#!/bin/bash

# DEBIAN_VERSION=<Set the debian version to create>
# ROOT_PASSWD=<Set the root password>

# Check if required files have been provided
if [ ! -f /root/files/config/configure.sh ] || \
   [ ! -f /root/files/config/packages ] || \
   [ ! -f /root/files/config/repositories-keys ] || \
   [ ! -f /root/files/config/repositories ]; then
     cat << EOF
Some required files are not available.

You need to mount a folder to /root/files with a config directory in it and the following files:
  - configure.sh
      This is the script where you can run custom actions within the image.
  - packages
      List the packages to install in the image
  - repositories
      Define repositories to add as in sources.list
  - repositories-keys
      Define keys for the additional repositories. Format of each line: <keyserver> <key id>

Example:
$ docker run -t --rm -v /home/user/my-folder:/root/files aitorpazos/create-debian-iso
EOF
  exit 1
fi

export HOME=/tmp/root

# Set noninteractive APT frontend
export DEBIAN_FRONTEND=noninteractive

# Install ISO building tools
apt-get update
apt-get install -y \
    debootstrap \
    squashfs-tools \
    xorriso \
    isolinux \
    syslinux-efi \
    grub-pc-bin \
    grub-efi-amd64-bin \
    mtools

# Create base directory
mkdir -p $HOME/LIVE_BOOT

# Bootstrap debian chroot
debootstrap \
    --arch=amd64 \
    --variant=minbase \
    ${DEBIAN_VERSION} \
    $HOME/LIVE_BOOT/chroot \
    http://ftp.us.debian.org/debian/

# Copy cutomisation files to chroot
cp -r /root/files/config/* $HOME/LIVE_BOOT/chroot/root/
cp /root/files/config/repositories $HOME/LIVE_BOOT/chroot/etc/apt/sources.list.d/custom-debian.list
cp /tmp/chroot-script.sh $HOME/LIVE_BOOT/chroot/root/chroot-script.sh
# Set execution flag
chmod +x $HOME/LIVE_BOOT/chroot/root/configure.sh
chmod +x $HOME/LIVE_BOOT/chroot/root/chroot-script.sh

# chroot into the bootstrap folder
chroot $HOME/LIVE_BOOT/chroot /root/chroot-script.sh ${ROOT_PASSWD}

# Prepare boot directories
mkdir -p $HOME/LIVE_BOOT/{staging/{EFI/boot,boot/grub/x86_64-efi,isolinux,live},tmp}

# Create squashfs
mksquashfs \
    $HOME/LIVE_BOOT/chroot \
    $HOME/LIVE_BOOT/staging/live/filesystem.squashfs \
    -e boot

# Copy kernel images and initrd
cp $HOME/LIVE_BOOT/chroot/boot/vmlinuz-* \
    $HOME/LIVE_BOOT/staging/live/vmlinuz && \
cp $HOME/LIVE_BOOT/chroot/boot/initrd.img-* \
    $HOME/LIVE_BOOT/staging/live/initrd

# Set ISOLINUX config. Used in BIOS boot
cat <<'EOF' >$HOME/LIVE_BOOT/staging/isolinux/isolinux.cfg
UI vesamenu.c32

MENU TITLE Boot Menu
DEFAULT linux
TIMEOUT 600
MENU RESOLUTION 640 480
MENU COLOR border       30;44   #40ffffff #a0000000 std
MENU COLOR title        1;36;44 #9033ccff #a0000000 std
MENU COLOR sel          7;37;40 #e0ffffff #20ffffff all
MENU COLOR unsel        37;44   #50ffffff #a0000000 std
MENU COLOR help         37;40   #c0ffffff #a0000000 std
MENU COLOR timeout_msg  37;40   #80ffffff #00000000 std
MENU COLOR timeout      1;37;40 #c0ffffff #00000000 std
MENU COLOR msg07        37;40   #90ffffff #a0000000 std
MENU COLOR tabmsg       31;40   #30ffffff #00000000 std

LABEL linux
  MENU LABEL Debian Live [BIOS/ISOLINUX]
  MENU DEFAULT
  KERNEL /live/vmlinuz
  APPEND initrd=/live/initrd boot=live

LABEL linux
  MENU LABEL Debian Live [BIOS/ISOLINUX] (nomodeset)
  MENU DEFAULT
  KERNEL /live/vmlinuz
  APPEND initrd=/live/initrd boot=live nomodeset
EOF

# Configure GRUB. Used in EFI/UEFI boot
cat <<'EOF' >$HOME/LIVE_BOOT/staging/boot/grub/grub.cfg
search --set=root --file /DEBIAN_CUSTOM

set default="0"
set timeout=30

# If X has issues finding screens, experiment with/without nomodeset.

menuentry "Debian Live [EFI/GRUB]" {
    linux ($root)/live/vmlinuz boot=live
    initrd ($root)/live/initrd
}

menuentry "Debian Live [EFI/GRUB] (nomodeset)" {
    linux ($root)/live/vmlinuz boot=live nomodeset
    initrd ($root)/live/initrd
}
EOF

# Early boot GRUB config for EFI boot
cat <<'EOF' >$HOME/LIVE_BOOT/tmp/grub-standalone.cfg
search --set=root --file /DEBIAN_CUSTOM
set prefix=($root)/boot/grub/
configfile /boot/grub/grub.cfg
EOF

# Point GRUB to boot filesystem
touch $HOME/LIVE_BOOT/staging/DEBIAN_CUSTOM

# Copy bootloader files
# BIOS files
cp /usr/lib/ISOLINUX/isolinux.bin "${HOME}/LIVE_BOOT/staging/isolinux/" && \
cp /usr/lib/syslinux/modules/bios/* "${HOME}/LIVE_BOOT/staging/isolinux/"
# EFI files
cp -r /usr/lib/grub/x86_64-efi/* "${HOME}/LIVE_BOOT/staging/boot/grub/x86_64-efi/"

# Generate bootable EFI grub image
grub-mkstandalone \
    --format=x86_64-efi \
    --output=$HOME/LIVE_BOOT/tmp/bootx64.efi \
    --locales="" \
    --fonts="" \
    "boot/grub/grub.cfg=$HOME/LIVE_BOOT/tmp/grub-standalone.cfg"

# Create UEFI boot disk image
(cd $HOME/LIVE_BOOT/staging/EFI/boot && \
    dd if=/dev/zero of=efiboot.img bs=1M count=20 && \
    mkfs.vfat efiboot.img && \
    mmd -i efiboot.img efi efi/boot && \
    mcopy -vi efiboot.img $HOME/LIVE_BOOT/tmp/bootx64.efi ::efi/boot/
)

# Create bootable ISO
xorriso \
    -as mkisofs \
    -iso-level 3 \
    -o "/root/files/debian-custom.iso" \
    -full-iso9660-filenames \
    -volid "DEBIAN_CUSTOM" \
    -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
    -eltorito-boot \
        isolinux/isolinux.bin \
        -no-emul-boot \
        -boot-load-size 4 \
        -boot-info-table \
        --eltorito-catalog isolinux/isolinux.cat \
    -eltorito-alt-boot \
        -e /EFI/boot/efiboot.img \
        -no-emul-boot \
        -isohybrid-gpt-basdat \
    -append_partition 2 0xef ${HOME}/LIVE_BOOT/staging/EFI/boot/efiboot.img \
    "${HOME}/LIVE_BOOT/staging"

