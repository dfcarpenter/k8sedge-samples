FROM mcr.microsoft.com/vscode/devcontainers/base:debian


# [Option] K9s version
ARG K9S_VER="0.26.3"
# [Option] Install zsh
ARG INSTALL_ZSH="true"
# [Option] Upgrade OS packages to their latest versions
ARG UPGRADE_PACKAGES="false"
# [Option] Enable non-root Docker access in container
ARG ENABLE_NONROOT_DOCKER="true"
# [Option] Use the OSS Moby Engine instead of the licensed Docker Engine
ARG USE_MOBY="true"
# [Option] Engine/CLI Version
ARG DOCKER_VERSION="latest"

# Enable new "BUILDKIT" mode for Docker CLI
ENV DOCKER_BUILDKIT=1

# Install needed packages and setup non-root user. Use a separate RUN statement to add your
# own dependencies. A user of "automatic" attempts to reuse an user ID if one already exists.
ARG USERNAME=automatic
ARG USER_UID=1000
ARG USER_GID=$USER_UID
COPY library-scripts/*.sh /tmp/library-scripts/
RUN apt-get update \
    && /bin/bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "true" "true" \
    # Use Docker script from script library to set things up
    && /bin/bash /tmp/library-scripts/docker-in-docker-debian.sh "${ENABLE_NONROOT_DOCKER}" "${USERNAME}" "${USE_MOBY}" "${DOCKER_VERSION}" \
    # Clean up
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts/

# Setup Kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin

# Setup k3d
RUN wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Setup k9s
RUN curl -LO https://github.com/derailed/k9s/releases/download/v${K9S_VER}/k9s_Linux_x86_64.tar.gz && \
    tar xvzf k9s_Linux_x86_64.tar.gz && \
    chmod +x ./k9s && \
    mv ./k9s /usr/local/bin && \
    rm ./k9s_Linux_x86_64.tar.gz ./README.md ./LICENSE

# Setup Helm
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash -s -- --version v3.9.4

# Setup mosquitto-clients
RUN apt-get update && \
    apt-get install mosquitto-clients -y 

# Install mqttui
RUN wget https://github.com/EdJoPaTo/mqttui/releases/download/v0.18.0/mqttui-v0.18.0-x86_64-unknown-linux-gnu.deb && \
    apt-get install ./mqttui-v0.18.0-x86_64-unknown-linux-gnu.deb && \
    rm -rf ./mqttui-v0.18.0-x86_64-unknown-linux-gnu.deb

USER vscode

# NOTE: we can't initialize k3d here because the docker daemon isn't running. That will only
# be possible once the devcontainer actually launches.

EXPOSE 1883
VOLUME [ "/var/lib/docker" ]

# Setting the ENTRYPOINT to docker-init.sh will start up the Docker Engine 
# inside the container "overrideCommand": false is set in devcontainer.json. 
# The script will also execute CMD if you need to alter startup behaviors.
ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]