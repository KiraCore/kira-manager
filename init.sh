#!/bin/bash

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
PSWD="$(whiptail --title 'KM2.0 Setup' --passwordbox 'Enter your root password to continue installation.' 10 60 3>&1 1>&2 2>&3)"

exitstatus=$?
if [[ $exitstatus != 0 ]] || [[ -z $PSWD ]]; then
    whiptail --title "KM2.0 Setup" --msgbox "Operation canceled" 10 60 
else
    whiptail --title "KM2.0 Setup" --msgbox "Success" 10 60
    break
fi
done

declare -A ESSENTIALS_NAMES
ESSENTIALS_NAMES[0]="update"
ESSENTIALS_NAMES[1]="golang_wget"
ESSENTIALS_NAMES[2]="golang_tar"
ESSENTIALS_NAMES[3]="docker_remove"
ESSENTIALS_NAMES[4]="docker_depend"
ESSENTIALS_NAMES[5]="docker_gpg"
ESSENTIALS_NAMES[6]="docker_set_stable"

declare -A ESSENTIALS
ESSENTIALS[0]="sudo apt get update -y <<< $PSWD"
ESSENTIALS[1]="wget https://dl.google.com/go/go$GO_VERSION.linux-$GOLANG_ARCH.tar.gz" 
ESSENTIALS[2]="sudo tar -C /usr/local -xvf go$GO_VERSION.linux-$GOLANG_ARCH.tar.gz"
ESSENTIALS[3]="sudo apt-get remove docker docker-engine docker.io containerd runc -y <<< $PSWD"
ESSENTIALS[4]="sudo apt-get install ca-certificates curl gnupg lsb-release -y <<< $PSWD"
ESSENTIALS[5]="curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg <<< $PSWD"
ESSENTIALS[6]="echo 'deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable' | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null <<< $PSWD"

ESSENTIALS_LEN=${#ESSENTIALS[@]}

{ 
    for (( i=0; i<${ESSENTIALS_LEN}; i++ )) ; do

        COUNTER=$((100/$ESSENTIALS_LEN*$i)) 
        echo "$COUNTER"
        echo "${ESSENTIALS[$i]}" >> log 
        eval $(echo "${ESSENTIALS[$i]}") &>eval.log

    done 

} | whiptail --gauge "Installing essentials..." 6 50 0

