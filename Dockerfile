FROM ubuntu:22.04

ARG VERSION=0.3.0
ARG BUILDTOOLS_VERSION=4.0.26
ARG BUILDTOOLS_SHA256=6938ec21608f6152632093f078a8d30eb2a7c9efa686e373f907a1b907e7be47

LABEL org.opencontainers.image.title="grinn-yocto-container" \
    org.opencontainers.image.ref.name="grinn-yocto-container" \
    org.opencontainers.image.description="Grinn Yocto Build Environment" \
    org.opencontainers.image.version="${VERSION}" \
    org.opencontainers.image.authors="Grinn <office@grinn-global.com>" \
    org.opencontainers.image.url="https://github.com/grinn-global/grinn-yocto-container" \
    org.opencontainers.image.source="https://github.com/grinn-global/grinn-yocto-container" \
    org.opencontainers.image.licenses="MIT"

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    DEBIAN_FRONTEND=noninteractive

COPY --chmod=0440 sudoers/yoctouser /etc/sudoers.d/yoctouser
COPY --chmod=0755 bin/install-yocto-buildtools.sh /usr/local/bin/install-yocto-buildtools.sh
COPY --chmod=0755 bin/entrypoint.sh /entrypoint.sh

# https://docs.yoctoproject.org/ref-manual/system-requirements.html#ubuntu-and-debian
RUN apt-get update && \
    apt-get install --yes --no-install-recommends \
        bash-completion \
        build-essential \
        chrpath \
        command-not-found \
        cpio \
        curl \
        debianutils \
        diffstat \
        dumb-init \
        file \
        g++-multilib \
        gawk \
        gcc \
        gcc-multilib \
        git \
        gosu \
        iputils-ping \
        libacl1 \
        liblz4-tool \
        locales \
        lsb-release \
        net-tools \
        python3 \
        python3-git \
        python3-jinja2 \
        python3-pexpect \
        python3-pip \
        python3-subunit \
        python3-virtualenv \
        rsync \
        socat \
        sudo \
        texinfo \
        tmux \
        tzdata \
        unzip \
        vim-tiny \
        wget \
        xz-utils \
        zstd \
        \
        debianutils \
        libegl1-mesa \
        libsdl1.2-dev \
        libstdc++-12-dev \
        lz4 \
        mesa-common-dev \
        pylint && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    \
    sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen && \
    \
    echo 'dash dash/sh boolean false' | debconf-set-selections && \
    dpkg-reconfigure dash && \
    \
    useradd -m -s /bin/bash yoctouser && \
    usermod -aG sudo yoctouser && \
    \
    install-yocto-buildtools.sh "${BUILDTOOLS_VERSION}" "${BUILDTOOLS_SHA256}"

WORKDIR /home/yoctouser

RUN rm .bash_logout .profile && \
    touch .sudo_as_admin_successful && \
    chown yoctouser:yoctouser .sudo_as_admin_successful && \
    sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' .bashrc && \
    sed -i "/^#export GCC_COLORS=/s/^#//" .bashrc && \
    printf '\n%s\n' 'export PS1="🐢 $PS1"' >> .bashrc && \
    printf '\n%s\n' ". /opt/poky/${BUILDTOOLS_VERSION}/environment-setup-x86_64-pokysdk-linux" >> .bashrc

ENTRYPOINT ["/usr/bin/dumb-init", "--", "/entrypoint.sh"]
CMD ["/bin/bash"]
