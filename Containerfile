FROM debian:12.5

ENV CMD_APT_INSTALL="apt-get install -y --no-install-recommends"

RUN apt-get update
# Install useful tools.
## 'ca-certificates' is not installed by default in Debian container images.
## https://stackoverflow.com/questions/66473954/no-installed-certificates-on-debianbuster-docker-image
## 'sudo' is required for the container to work as a Toolbox.
RUN ${CMD_APT_INSTALL} apt-file bash-completion ca-certificates clamav clamav-freshclam jq less man-db mlocate software-properties-common rsync sudo vim
# Install compression tools.
RUN ${CMD_APT_INSTALL} gzip p7zip-full unzip zip zstd
# Install network tools.
RUN ${CMD_APT_INSTALL} curl dnsutils iproute2 iputils-ping netcat-traditional nmap openssh-client openssl wget
# Install programming languages and tools.
RUN ${CMD_APT_INSTALL} build-essential git git-review gcc golang make openjdk-17-jdk python3 python3-pip python3-virtualenv virtualenv
## GitHub CLI ('gh' command).
## https://github.com/cli/cli/blob/trunk/docs/install_linux.md
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" >> /etc/apt/sources.list.d/github-cli.list && apt-get update && ${CMD_APT_INSTALL} gh
## Install programming language linters.
RUN ${CMD_APT_INSTALL} python3-pylint-common shellcheck
# Install ZSH.
RUN ${CMD_APT_INSTALL} zsh
# Install the Docker Engine.
RUN ${CMD_APT_INSTALL} docker.io
# Sphinx for Root Pages documentation development.
RUN ${CMD_APT_INSTALL} python3-sphinx python3-sphinx-rtd-theme
# Distrobox support.
## distrobox-init installs these packages. We pre-install them now so the container can start instantly.
## https://github.com/89luca89/distrobox/blob/1.5.0.2/distrobox-init#L419
RUN ${CMD_APT_INSTALL} apt-utils bash bash-completion bc bzip2 curl dialog diffutils findutils gnupg gnupg2 gpgsm hostname iproute2 iputils-ping keyutils less libcap2-bin libegl1-mesa libgl1-mesa-glx libkrb5-3 libnss-mdns libnss-myhostname libvte-2.9*-common libvte-common libvulkan1 locales lsof man-db manpages mesa-vulkan-drivers mtr ncurses-base openssh-client passwd pigz pinentry-curses procps rsync sudo tcpdump time traceroute tree tzdata unzip util-linux wget xauth xz-utils zip
# Install Linux distribution agnostic packages.
COPY distro-agnostic-tools.sh /usr/local/bin/
RUN /usr/local/bin/distro-agnostic-tools.sh

# Cleanup.
RUN apt-get clean all

VOLUME ["/home_real"]

# code-server.
EXPOSE 2003
#CMD code-server --bind-addr 0.0.0.0:2003
# Find the auto-generated `code-server` password:
# $ podman exec ekultails-dev cat /root/.config/code-server/config.yaml | grep password:

# Toolbox support.
ENV NAME=ekultails-dev VERSION=rolling
LABEL com.github.containers.toolbox="true" \
  name="$NAME" \
  version="$VERSION"
RUN echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/toolbox
CMD ["/bin/bash"]
