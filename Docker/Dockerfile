FROM ubuntu:24.04

# ------------------------------------------------------------------------------
# Packages
# ------------------------------------------------------------------------------
RUN echo "## Update and install packages" \
    && apt-get -qq -y update \
    && DEBIAN_FRONTEND="noninteractive" TZ="Europe/Paris" \
    && apt-get -qq -y install --no-install-recommends \
        wget \
        openjdk-21-jre-headless \
    && echo "## Done"

# ------------------------------------------------------------------------------
# User
# ------------------------------------------------------------------------------
RUN echo "## Create Minecraft user" \
    && groupadd --system --gid 999 minecraft \
    && useradd --system --uid 999 --gid 999 --home-dir="/srv/minecraft" \
        --create-home --shell="/bin/false" minecraft \
    && echo "## Done"

# ------------------------------------------------------------------------------
# Server
# ------------------------------------------------------------------------------
EXPOSE 25565/tcp

USER minecraft
WORKDIR /srv/minecraft

COPY --chown=minecraft:minecraft Docker/server.properties server.properties
# COPY --chown=minecraft:minecraft Docker/start.sh /
# RUN chmod +x /start.sh

RUN echo "## Install Minecraft version 1.20.6" \
    && wget https://piston-data.mojang.com/v1/objects/145ff0858209bcfc164859ba735d4199aafa1eea/server.jar \
    && echo "eula=true" > eula.txt \
    && echo "## Done"

ENTRYPOINT ["/usr/bin/java", "-Xms1024M", "-Xmx1536M", "-jar", "server.jar", "--nogui"]
# ENTRYPOINT ["/start.sh"]
