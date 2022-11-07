#!/bin/bash

# this runs as part of pre-build

echo "on-create start"
echo "$(date +'%Y-%m-%d %H:%M:%S')    on-create start" >> "$HOME/status"


# opc-plc-server
docker pull mcr.microsoft.com/iotedge/opc-plc:2.5.2

# create local registry
docker network create k3d
k3d registry create registry.localhost --port 5500
docker network connect k3d k3d-registry.localhost

echo "adding k9s"
curl -fSL -o "/usr/local/bin/k9s" "https://github.com/derailed/k9s/releases/download/v0.26.3/k9s_Linux_x86_64"
sudo chmod a+x /usr/local/bin/k9s

echo "adding grafana tanka cli"
curl -fSL -o "/usr/local/bin/tk" "https://github.com/grafana/tanka/releases/download/v0.22.1/tk-linux-amd64"
chmod a+x "/usr/local/bin/tk"

echo "adding jsonnet bundler for use with Tanka"
sudo curl -Lo /usr/local/bin/jb https://github.com/jsonnet-bundler/jsonnet-bundler/releases/latest/download/jb-linux-amd64
sudo chmod a+x /usr/local/bin/jb

# only run apt upgrade on pre-build
if [ "$CODESPACE_NAME" = "null" ]
then
    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get autoremove -y
    sudo apt-get clean -y
fi

echo "on-create complete"
echo "$(date +'%Y-%m-%d %H:%M:%S')    on-create complete" >> "$HOME/status"
