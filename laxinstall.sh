#!/bin/bash
b=$(tput bold)
n=$(tput sgr0)

if [ "$EUID" -ne 0 ]
  then echo "${b} Run as elevated user (sudo)${n}"
  exit
fi

read -p "${b} Enter your non-root username:${n} " USERNAME

echo "${b} Updating apt${n}"
apt-get -y update >>/dev/null 2>&1

echo "${b} Installing dependencies${n}"
apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common >>/dev/null 2>&1

echo "${b} Adding gpg key for Docker repo${n}"
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - >>/dev/null 2>&1

echo "${b} Adding Docker repo${n}"
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" >>/dev/null 2>&1

echo "${b} Updating apt after changes${n}"
apt-get -y update >>/dev/null 2>&1

echo "${b} Installing latest release of Docker-CE"${n}
apt-get install docker-ce >>/dev/null 2>&1
groupadd docker >>/dev/null 2>&1
usermod -aG docker $USERNAME >>/dev/null 2>&1

echo "${b} Installing Docker-Compose${n}"
sudo curl -L "https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose >>/dev/null 2>&1
sudo chmod +x /usr/local/bin/docker-compose >>/dev/null 2>&1
docker-compose --version >>/dev/null 2>&1

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

echo "${b} Starting Postgres and Chainlink containers${n}"
docker-compose build
docker-compose up -d

echo "${b} Check running containers${n}"
docker container ps -a
docker ps -q | xargs -n 1 docker inspect --format '{{ .Name }} {{range .NetworkSettings.Networks}} {{.IPAddress}}{{end}}' | sed 's#^/##';

echo "${b}Your chainlink node should be available from this device at:${n}"
echo "http://localhost:6688"

echo "${b}Special thanks to https://github.com/thodges-gh.${n}"
