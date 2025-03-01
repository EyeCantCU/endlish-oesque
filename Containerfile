ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-silverblue}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"
ARG SOURCE_IMAGE="${SOURCE_IMAGE:-$BASE_IMAGE_NAME-$IMAGE_FLAVOR}"
ARG BASE_IMAGE="ghcr.io/ublue-os/${SOURCE_IMAGE}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-37}"

FROM ${BASE_IMAGE}:${FEDORA_MAJOR_VERSION} AS endlish-oesque

ARG IMAGE_NAME="${IMAGE_NAME}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION}"

COPY etc /etc
COPY usr /usr

ADD packages.json /tmp/packages.json
ADD build.sh /tmp/build.sh

RUN /tmp/build.sh && \
    wget https://copr.fedorainfracloud.org/coprs/ublue-os/gnome-software/repo/fedora-${FEDORA_VERSION}/ublue-os-gnome-software-fedora-${FEDORA_VERSION}.repo -O /etc/yum.repos.d/ublue-os-gnome-software.repo && \
    rpm-ostree override replace --experimental --from repo=copr:copr.fedorainfracloud.org:ublue-os:gnome-software gnome-software gnome-software-rpm-ostree && \
    pip install --prefix=/usr yafti && \
    curl -sL $(curl -s https://api.github.com/repos/rsms/inter/releases | jq -r '.[0].assets[0].browser_download_url') -o /tmp/inter.zip && \
    mkdir -p /tmp/inter /usr/share/fonts/inter && \
    unzip /tmp/inter.zip -d /tmp/inter/ && \
    mv /tmp/inter/*.ttf /tmp/inter/*.ttc /tmp/inter/LICENSE.txt /usr/share/fonts/inter/ && \
    systemctl unmask dconf-update.service && \
    systemctl enable dconf-update.service && \
    systemctl enable rpm-ostree-countme.service && \
    fc-cache -f /usr/share/fonts/inter && \
    rm -rf /tmp/* /var/* && \
    ostree container commit && \
    mkdir -p /var/tmp && \
    chmod -R 1777 /var/tmp

RUN rm -rf /tmp/* /var/*
RUN ostree container commit
