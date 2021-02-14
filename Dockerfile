FROM debian:buster

ADD create-iso.sh /usr/local/bin/create-iso.sh
ADD chroot-script.sh /tmp/chroot-script.sh

RUN chmod +x /usr/local/bin/create-iso.sh

ENV DEBIAN_VERSION=buster \
    ROOT_PASSWD=toor

ENTRYPOINT [ "/usr/local/bin/create-iso.sh" ]
