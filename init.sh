#!/bin/bash

GO_VERSION="1.15.11"
GOROOT="/usr/local/go"
GOPATH="/home/go"
GOCACHE="/home/go/cache"
GOBIN="${GOROOT}/bin"
ARCHITECTURE=$(uname -m)

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

declare -A ESSENTIALS
ESSENTIALS["update"]="sudo apt get update -y <<< $PSWD"
ESSENTIALS["golang_wget"]="wget https://dl.google.com/go/go$GO_VERSION.linux-$GOLANG_ARCH.tar.gz" 
ESSENTIALS["golang_tar"]="tar -C /usr/local -xvf go$GO_VERSION.linux-$GOLANG_ARCH.tar.gz"
ESSENTIALS["docker_remove"]="sudo apt-get remove docker docker-engine docker.io containerd runc -y <<< $PSWD"
ESSENTIALS["docker_depend"]="sudo apt-get install ca-certificates curl gnupg lsb-release -y <<< $PSWD"
ESSENTIALS["docker_gpg"]="curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg <<< $PSWD"
ESSENTIALS["docker_set_stable"]="echo 'deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
                                     https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable' | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null <<< $PSWD"
{
i=0
for key in ${!ESSENTIALS[@]}; do
    sleep 2
    echo "${key} ${ESSENTIALS[${key}]}" >> log
    echo $i
    i+=1
done
} | whiptail --gauge "Installing essentials..." 6 50 0