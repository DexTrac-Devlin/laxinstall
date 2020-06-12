#!/bin/bash
b=$(tput bold)
n=$(tput sgr0)

if [ "$EUID" -ne 0 ]
  then echo "${b} Run as elevated user (sudo)${n}"
  exit
fi

read -p "${b} Enter your non-root username:${n} " USERNAME

aptInstall () {
echo " Updating apt"
apt-get -y update >>/dev/null 2>&1

echo " Installing dependencies"
apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common >>/dev/null 2>&1

echo " Adding gpg key for Docker repo"
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - >>/dev/null 2>&1

echo " Adding Docker repo"
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" >>/dev/null 2>&1

echo " Updating apt after changes"
apt-get -y update >>/dev/null 2>&1

echo " Installing latest release of Docker-CE"
apt-get install docker-ce >>/dev/null 2>&1
groupadd docker >>/dev/null 2>&1
sudo usermod -aG docker $USERNAME >>/dev/null 2>&1

echo " Installing Docker-Compose"
sudo curl -L "https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose >>/dev/null 2>&1
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
}

yumInstall (){
echo " Updating yum"
yum check-update

echo " Installing dependencies"
yum remove docker* >>/dev/null 2>&1
yum install -y yum-utils device-mapper-persistent-data lvm2 >>/dev/null 2>&1

echo " Adding Docker repo"
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo >>/dev/null 2>&1

echo " Updating yum after changes"
yum check-update >>/dev/null 2>&1

echo " Installing latest release of Docker-CE"
yum install docker-ce docker-ce-cli containerd.io >>/dev/null 2>&1

echo " Starting Docker-CE service"
systemctl start docker >>/dev/null 2>&1
}


apt=`command -v apt-get`
yum=`command -v yum`

if [ -n "$apt" ]; then
    aptInstall
elif [ -n "$yum" ]; then
    yumInstall
else
    echo "Err: apt or yum not detected.";
    exit 1;
fi


echo " Cloning github.com/thodges-gh/min-cl-docker-compose"
git clone https://github.com/thodges-gh/min-cl-docker-compose.git >>/dev/null 2>&1
cd min-cl-docker-compose
chmod +x start.sh stop.sh

WORKINGDIR=$(pwd)

read -p " ${b}Enter e-mail address to be used for GUI access: ${n}"  EMAIL
sed -i "s|test@example.com|$EMAIL|g" $WORKINGDIR/secrets/apicredentials

read -s -p " ${b}Enter password to be used for GUI access: ${n}" GUIPASS
sed -i "s|password|$GUIPASS|g" $WORKINGDIR/secrets/apicredentials

echo ""
read -n 1 -p "Which network do you want to use? (${b}M${n})ainnet or (${b}R${n})opsten?" ANS0;
case $ANS0 in
  m|M )
    echo ""
    echo "You selected Mainnet."
    FIEWSNETWORK=wss://cl-ropsten.fiews.io/v1/
    sed -i "s|ETH_CHAIN_ID=3|ETH_CHAIN_ID=1|g" $WORKINGDIR/chainlink.env
    sed -i "s|LINK_CONTRACT_ADDRESS=0x20fE562d797A42Dcb3399062AE9546cd06f63280|#LINK_CONTRACT_ADDRESS=0x20fE562d797A42Dcb3399062AE9546cd06f63280|g" $WORKINGDIR/chainlink.env;;
  r|R )
    echo ""
    echo "You selected Ropsten."
    FIEWSNETWORK=wss://cl-main.fiews.io/v1/;;
  * )
  echo "invalid";;
esac

echo ""
read -n 1 -p "Are you using Fiews.io for your Etheruem Connection? (${b}Y${n})es or(${b}N${n})o" ANS1;
case $ANS1 in
  y|Y )
    echo ""
    read -p "${b}Please enter your Fiews.io API key.${n}" FIEWSAPI
    sed -i "s|CHANGEME|$FIEWSNETWORK$FIEWSAPI|g" $WORKINGDIR/chainlink.env;;
  n|N )
    read -p "${b} Enter Ethereum endpoint URL/APIkey:${n}" ETHURL
    sed -i "s|CHANGEME|$ETHURL|g" $WORKINGDIR/chainlink.env;;
  * )
  echo "invalid";;
esac

echo " Starting Postgres and Chainlink containers"
docker-compose build
docker-compose up -d

echo " Check running containers"
docker container ps -a

echo " ${b}Your chainlink node should be available from this device at:${n}"
echo "http://localhost:6688"

echo "${b}Special thanks to https://github.com/thodges-gh. ${n}"
