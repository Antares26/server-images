FROM rockylinux:9.3
RUN dnf -y upgrade

RUN dnf install -y wget tar glibc.i686 libstdc++.i686
RUN useradd -m -s /bin/bash steam
RUN mkdir -p /home/steam/steamcmd && chown -R steam:steam /home/steam
RUN mkdir -p /srv/kf2 && chown steam:steam /srv/kf2

ARG STEAM_CMD_URL="https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"

ENV SERVER_GAME_PORT=6213
ENV SERVER_QUERY_PORT=26015
ENV WEBSERVER_PORT=8081

ENV SERVER_ADMIN_PASSWORD="s0meD1fficultP2ssw0rd!"
ENV SERVER_ENTRY_PASSWORD="EntryPassword"
ENV SERVER_DIFFICULTY=2
ENV SERVER_NAME="Killing Floor 2 Server"
ENV SERVER_MAXPLAYERS=6
ENV ZEDS_SKIN_INDEX=4

USER steam
WORKDIR /home/steam/steamcmd
RUN TMP_DIR=$(mktemp -d) && \
    wget "$STEAM_CMD_URL" --output-document="$TMP_DIR/steamcmd.tar.gz" && \
    tar zxvf "$TMP_DIR/steamcmd.tar.gz" && \
    rm -Rf "$TMP_DIR"
RUN chmod 755 steamcmd.sh
RUN ./steamcmd.sh +force_install_dir /srv/kf2 +login anonymous +app_update 232130 validate +quit ||true

WORKDIR /home/steam
COPY --chown=steam:steam start_server.sh .
RUN chmod 754 start_server.sh

# We need to start the server a first time to let it set the initial configs up
RUN /srv/kf2/Binaries/Win64/KFGameSteamServer.bin.x86_64 KF-CarillonHamlet & \
    PID=$! && \
    sleep 30 && \
    kill $PID

ENTRYPOINT ["/home/steam/start_server.sh"]
