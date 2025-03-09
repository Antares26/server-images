#!/bin/bash

ENGINE_FILE="/srv/kf2/KFGame/Config/LinuxServer-KFEngine.ini"
GAME_FILE="/srv/kf2/KFGame/Config/LinuxServer-KFGame.ini"
WEBSERVER_FILE="/srv/kf2/KFGame/Config/KFWeb.ini"

# Validate that all the required environment variables are set
if [[ -z "$SERVER_MAXPLAYERS" || -z "$SERVER_DIFFICULTY" || -z "$SERVER_ADMIN_PASSWORD" || -z "$SERVER_ENTRY_PASSWORD" || 
      -z "$SERVER_NAME" || -z "$SERVER_GAME_PORT" || -z "$SERVER_QUERY_PORT" || -z "$WEBSERVER_PORT"  ]]; then
    echo "Error: Environment variables are missing."
    exit 1
fi

# Ensure all required sections are present in the files
if ! grep -q "^\[Engine.GameEngine\]" "$ENGINE_FILE"; then
    echo -e "\n[Engine.GameEngine]" >> "$ENGINE_FILE"
fi
if ! grep -q "^\[Engine.GameInfo\]" "$GAME_FILE"; then
    echo -e "\n[Engine.GameInfo]" >> "$GAME_FILE"
fi
if ! grep -q "^\[Engine.AccessControl\]" "$GAME_FILE"; then
    echo -e "\n[Engine.AccessControl]" >> "$GAME_FILE"
fi
if ! grep -q "^\[Engine.GameReplicationInfo\]" "$GAME_FILE"; then
    echo -e "\n[Engine.GameReplicationInfo]" >> "$GAME_FILE"
fi
if ! grep -q "^\[IpDrv.WebServer\]" "$WEBSERVER_FILE"; then
    echo -e "\n[IpDrv.WebServer]" >> "$WEBSERVER_FILE"
fi

# Set all custom settings
sed -i "/^\[Engine.GameEngine\]/,/^\[/ { /bUsedForTakeover=/d }" "$ENGINE_FILE"
sed -i "/^\[Engine.GameEngine\]/a bUsedForTakeover=FALSE" "$ENGINE_FILE"

sed -i "/^\[Engine.GameInfo\]/,/^\[/ { /MaxPlayers=/d }" "$GAME_FILE"
sed -i "/^\[Engine.GameInfo\]/,/^\[/ { /GameDifficulty=/d }" "$GAME_FILE"
sed -i "/^\[Engine.GameInfo\]/a MaxPlayers=$SERVER_MAXPLAYERS" "$GAME_FILE"
sed -i "/^\[Engine.GameInfo\]/a GameDifficulty=${SERVER_DIFFICULTY}.000000" "$GAME_FILE"

sed -i "/^\[Engine.AccessControl\]/,/^\[/ { /AdminPassword=/d }" "$GAME_FILE"
sed -i "/^\[Engine.AccessControl\]/,/^\[/ { /GamePassword=/d }" "$GAME_FILE"
sed -i "/^\[Engine.AccessControl\]/a AdminPassword=$SERVER_ADMIN_PASSWORD" "$GAME_FILE"
sed -i "/^\[Engine.AccessControl\]/a GamePassword=$SERVER_ENTRY_PASSWORD" "$GAME_FILE"

sed -i "/^\[Engine.GameReplicationInfo\]/,/^\[/ { /ServerName=/d }" "$GAME_FILE"
sed -i "/^\[Engine.GameReplicationInfo\]/a ServerName=$SERVER_NAME" "$GAME_FILE"

sed -i "/^\[IpDrv.WebServer\]/,/^\[/ { /ListenPort=/d }" "$WEBSERVER_FILE"
sed -i "/^\[IpDrv.WebServer\]/,/^\[/ { /bEnabled=/d }" "$WEBSERVER_FILE"
sed -i "/^\[IpDrv.WebServer\]/a ListenPort=$WEBSERVER_PORT" "$WEBSERVER_FILE"
sed -i "/^\[IpDrv.WebServer\]/a bEnabled=true" "$WEBSERVER_FILE"

# Start the server
/srv/kf2/Binaries/Win64/KFGameSteamServer.bin.x86_64 KF-CarillonHamlet?Game=KFGameContent.KFGameInfo_Endless?SeasonalSkinsIndex=$ZEDS_SKIN_INDEX \
    -Port=$SERVER_GAME_PORT -QueryPort=$SERVER_QUERY_PORT
