ARG DISTRO=debian
ARG DISTRO_VERSION=buster
FROM ${DISTRO}:${DISTRO_VERSION}

ARG DISTRO
ARG DISTRO_VERSION

ADD create-iso.sh /usr/local/bin/create-iso.sh
ADD chroot-script.sh /tmp/chroot-script.sh

RUN chmod +x /usr/local/bin/create-iso.sh

ENV DISTRO=${DISTRO} \
    DISTRO_VERSION=${DISTRO_VERSION} \
    OUTPUT_FILE=${DISTRO}-${DISTRO_VERSION}-custom.iso \
    ROOT_PASSWD=toor

ENTRYPOINT [ "/usr/local/bin/create-iso.sh" ]
