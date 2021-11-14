#!/bin/bash

#To avoid password leakage
export HISTIGNORE='*sudo -S*'

USER=$(logname)

GO_VERSION="1.15.11"
GOROOT="/usr/local/go"
GOPATH="/home/go"
GOCACHE="/home/go/cache"
GOBIN="${GOROOT}/bin"
ARCHITECTURE=$(uname -m)

if [[ "${ARCHITECTURE,,}" == *"arm"* ]] || [[ "${ARCHITECTURE,,}" == *"aarch"* ]] ; then
    GOLANG_ARCH="arm64"
else
    GOLANG_ARCH="amd64"
fi

while true; do
PSWD="$(whiptail --title 'KM2.0 Setup' --passwordbox 'Enter your $USER password to continue installation.' 10 60 3>&1 1>&2 2>&3)"

exitstatus=$?
if [[ $exitstatus != 0 ]] || [[ -z $PSWD ]]; then
    whiptail --title "KM2.0 Setup" --msgbox "Operation canceled" 10 60 
else
    whiptail --title "KM2.0 Setup" --msgbox "Success" 10 60
    break
fi
done

declare -A ESSENTIALS_NAMES
ESSENTIALS_NAMES[0]="Updating packages..."
ESSENTIALS_NAMES[1]="Downloading golang..."
ESSENTIALS_NAMES[2]="Unpacking golang..."
ESSENTIALS_NAMES[3]="Removing old docker packges..."
ESSENTIALS_NAMES[4]="Installing docker dependencies..."
ESSENTIALS_NAMES[5]="Handling gpg..."
ESSENTIALS_NAMES[6]="Seting docker repo..."
ESSENTIALS_NAMES[7]="Installing docker..."

declare -A ESSENTIALS
ESSENTIALS[0]="sudo -S <<< \"$PSWD\" apt-get update -y >> log"
ESSENTIALS[1]="wget https://dl.google.com/go/go$GO_VERSION.linux-$GOLANG_ARCH.tar.gz >> log" 
ESSENTIALS[2]="sudo -S -k <<< \"$PSWD\" tar -C /usr/local -xvf go$GO_VERSION.linux-$GOLANG_ARCH.tar.gz >> log"
ESSENTIALS[3]="sudo -S -k <<< \"$PSWD\" apt-get remove docker docker-engine docker.io containerd runc -y >> log"
ESSENTIALS[4]="sudo -S -k <<< \"$PSWD\" apt-get install ca-certificates curl gnupg lsb-release -y >> log"
ESSENTIALS[5]="curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo -S -k <<< \"$PSWD\" gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg >> log"
ESSENTIALS[6]="sudo -S -k <<< \"$PSWD\" tee /etc/apt/sources.list.d/docker.list <<< 'deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu focal stable'"
ESSENTIALS[7]="sudo -S -k <<< \"$PSWD\" apt-get install docker-ce docker-ce-cli containerd.io"

ESSENTIALS_LEN=${#ESSENTIALS[@]}

{ 
    for (( i=0; i<${ESSENTIALS_LEN}; i++ )) ; do

        COUNTER=$((100/$ESSENTIALS_LEN*$i)) 
        echo -e "XXX\n$COUNTER\\${ESSENTIALS_NAMES[$i]}\nXXX"
        echo "${ESSENTIALS[$i]}" >> log 
        eval $(echo "${ESSENTIALS[$i]}") &>eval.log

    done 

} | whiptail --title 'KM2.0 Setup' --gauge "Installing essentials..." 6 50 0

