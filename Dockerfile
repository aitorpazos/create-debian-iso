ARG DISTRO=debian
ARG DISTRO_VERSION=bullseye
FROM ${DISTRO}:${DISTRO_VERSION}

ARG DISTRO
ARG DISTRO_VERSION
ARG DISTRO_FLAVOR=${DISTRO_VERSION}

ADD create-iso.sh /usr/local/bin/create-iso.sh
ADD chroot-script.sh /tmp/chroot-script.sh

RUN chmod +x /usr/local/bin/create-iso.sh

ENV DISTRO=${DISTRO} \
    DISTRO_VERSION=${DISTRO_VERSION} \
    DISTRO_FLAVOR=${DISTRO_FLAVOR} \
    OUTPUT_FILE=${DISTRO}-${DISTRO_FLAVOR}-custom.iso \
    ROOT_PASSWD=toor

ENTRYPOINT [ "/usr/local/bin/create-iso.sh" ]
