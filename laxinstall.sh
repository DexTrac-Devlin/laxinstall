#!/bin/bash
b=$(tput bold)
n=$(tput sgr0)

if [ "$EUID" -ne 0 ]
  then echo "${b} Run as elevated user (sudo)${n}"
  exit
fi

read -p "${b} Enter your non-root username:${n} " USERNAME

echo "${b} Updating apt${n}"
apt-get -y update

echo "${b} Installing dependencies${n}"
apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common

echo "${b} Adding gpg key for Docker repo${n}"
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -

echo "${b} Adding Docker repo${n}"
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"

echo "${b} Updating apt after changes${n}"
apt-get -y update

echo "${b} Installing latest release of Docker-CE"${n}
apt-get install docker-ce
groupadd docker
usermod -aG docker $USERNAME

echo "${b} Installing Docker-Compose${n}"
sudo curl -L "https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

git clone https://github.com/thodges-gh/min-cl-docker-compose.git
cd min-cl-docker-compose
chmod +x start.sh stop.sh

read -p "${b} Enter Ethereum endpoint URL/APIkey:${n} " ETHURL

WORKINGDIR=$(pwd)
sed -i "s|CHANGEME|$ETHURL|g" $WORKINGDIR/chainlink.env

read -p "${b} Enter e-mail address to be used for GUI access:${n} "  EMAIL

sed -i "s|test@example.com|$EMAIL|g" $WORKINGDIR/secrets/apicredentials

read -s -p "${b} Enter password to be used for GUI access:${n} " GUIPASS

sed -i "s|password|$GUIPASS|g" $WORKINGDIR/secrets/apicredentials

echo "${b} Starting Chainlink and Postgres containers${n}"
more $WORKINGDIR/chainlink.env

echo "${b} Starting Postgres and Chainlink containers${n}"
docker-compose build
docker-compose up -d

echo "${b} Check running containers${n}"
docker container ps -a

echo "${b}Your chainlink node should be available from this device at:${n}"
echo "http://localhost:6688"

echo "${b}Special thanks to https://github.com/thodges-gh.${n}"
