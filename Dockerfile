FROM jupyter/base-notebook:latest

# Install .NET CLI dependencies

ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

WORKDIR ${HOME}

USER root
RUN apt-get update
RUN apt-get install -y curl

ENV \
    # Enable detection of running in a container
    DOTNET_RUNNING_IN_CONTAINER=true \
    # Enable correct mode for dotnet watch (only mode supported in a container)
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    # Skip extraction of XML docs - generally not useful within an image/container - helps performance
    NUGET_XMLDOC_MODE=skip \
    # Opt out of telemetry until after we install jupyter when building the image, this prevents caching of machine id
    DOTNET_TRY_CLI_TELEMETRY_OPTOUT=true

# Install .NET CLI dependencies
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        libc6 \
        libgcc1 \
        libgssapi-krb5-2 \
        libicu66 \
        libssl1.1 \
        libstdc++6 \
        zlib1g \
    && rm -rf /var/lib/apt/lists/*

# Install .NET Core SDK

# When updating the SDK version, the sha512 value a few lines down must also be updated.
ENV DOTNET_SDK_VERSION 3.1.301

RUN dotnet_sdk_version=3.1.301 \
    && curl -SL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/$dotnet_sdk_version/dotnet-sdk-$dotnet_sdk_version-linux-x64.tar.gz \
    && dotnet_sha512='dd39931df438b8c1561f9a3bdb50f72372e29e5706d3fb4c490692f04a3d55f5acc0b46b8049bc7ea34dedba63c71b4c64c57032740cbea81eef1dce41929b4e' \
    && echo "$dotnet_sha512 dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -ozxf dotnet.tar.gz -C /usr/share/dotnet \
    && rm dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    # Trigger first run experience by running arbitrary cmd
    && dotnet help

# Copy notebooks

COPY ./notebooks/ ${HOME}/notebooks/

# Copy package sources

COPY ./NuGet.config ${HOME}/nuget.config

RUN chown -R ${NB_UID} ${HOME}
USER ${USER}

#Install nteract 
RUN pip install nteract_on_jupyter

# Install lastest build from master branch of Microsoft.DotNet.Interactive from myget
RUN dotnet tool install -g Microsoft.dotnet-interactive --add-source "https://dotnet.myget.org/F/dotnet-try/api/v3/index.json"

#latest stable from nuget.org
#RUN dotnet tool install -g Microsoft.dotnet-interactive --add-source "https://api.nuget.org/v3/index.json"

ENV PATH="${PATH}:${HOME}/.dotnet/tools"
RUN echo "$PATH"

# Install kernel specs
RUN dotnet interactive jupyter install

# Enable telemetry once we install jupyter for the image
ENV DOTNET_TRY_CLI_TELEMETRY_OPTOUT=false

# Set root to notebooks
WORKDIR ${HOME}/notebooks/

# -> DOCKER Container Section:
# -- Added step to include Docker inside the container for Binder use:
# -> MT 07/13/2020

USER root
## -> Going wild! Try changing sudoers:
#cp /etc/sudoers ~/sudoers.bak
RUN apt-get update \
 && apt-get install -y sudo
#Already exist: RUN adduser --disabled-password --gecos '' jovyan
RUN adduser jovyan sudo
#RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN echo 'jovyan ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN groupadd docker
RUN usermod -a -G docker jovyan
## - SUDO fix for error: "sudo: setrlimit(RLIMIT_CORE): Operation not permitted"
RUN echo "Set disable_coredump false" >> /etc/sudo.conf
## -> Continue after sudoer update:
RUN apt-get update \
    && apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common \
    lxc \
    iptables
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
RUN add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable" 
RUN apt-get update
RUN apt-get install -y docker-ce docker-ce-cli containerd.io
RUN apt-get update
## - Add fix for docker.sock:> "permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock"
#RUN chown jovyan:docker /var/run/docker.sock
#RUN chown -R "{$USER}":"{$USER}" /home/"{$USER}"/.docker 
#RUN chmod _R g+rwx "{$HOME}/.docker" 
##-
#RUN apt-get update 
#RUN service docker start
#RUN service docker status
