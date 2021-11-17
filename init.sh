#!/bin/bash

#To avoid password leakage
export HISTIGNORE='*sudo -S*'

WHOAMI="$(whoami)"
if [[ $WHOAMI == "root" ]]; then
    whiptail --title "KM2.0 Setup" --msgbox "Plesase create a sudo user first. You can't proceed as root." 10 60
    exit 1
fi

GO_VERSION="1.15.11"
GOROOT="/usr/local/go"
GOPATH="/home/go"
GOCACHE="/home/go/cache"
GOBIN="${GOROOT}/bin"
GO="${GOBIN}/go"
ARCHITECTURE=$(uname -m)


if [[ "${ARCHITECTURE,,}" == *"arm"* ]] || [[ "${ARCHITECTURE,,}" == *"aarch"* ]] ; then
    GOLANG_ARCH="arm64"
else
    GOLANG_ARCH="amd64"
fi

while true; do
PSWD="$(whiptail --title 'KM2.0 Setup' --passwordbox 'Enter your sudo password to continue installation.' 10 60 3>&1 1>&2 2>&3)"

exitstatus=$?
if [[ $exitstatus != 0 ]] || [[ -z $PSWD ]]; then
    whiptail --title "KM2.0 Setup" --msgbox "Operation canceled" 10 60 
else
    whiptail --title "KM2.0 Setup" --msgbox "Success" 10 60
    break
fi
done

declare -A ESSENTIALS_OPERATIONS
ESSENTIALS_OPERATIONS[0]="Updating packages..."
ESSENTIALS_OPERATIONS[1]="Downloading golang..."
ESSENTIALS_OPERATIONS[2]="Unpacking golang..."

declare -A ESSENTIALS
ESSENTIALS[0]="sudo -S <<< \"$PSWD\" apt-get update -y >> log"
ESSENTIALS[1]="wget https://dl.google.com/go/go$GO_VERSION.linux-$GOLANG_ARCH.tar.gz >> log" 
ESSENTIALS[2]="sudo -S <<< \"$PSWD\" tar -C /usr/local -xvf go$GO_VERSION.linux-$GOLANG_ARCH.tar.gz >> log"

ESSENTIALS_LEN=${#ESSENTIALS[@]}

{ 
    for (( i=0; i<${ESSENTIALS_LEN}; i++ )) ; do

        COUNTER=$((100/$ESSENTIALS_LEN*$i)) 
        echo -e "XXX\n$COUNTER\n${ESSENTIALS_OPERATIONS[$i]}\nXXX"
        echo "${ESSENTIALS[$i]}" >> log 
        eval $(echo "${ESSENTIALS[$i]}") &>eval.log
        ##[NOT TESTED]##
        if [[ $? != 0 ]]; then
            whiptail --title "KM2.0 Setup" --msgbox "Installation of essentials faield..." 10 60
            echo "${ESSENTIALS[$i]}"
            break
            exit 1
        fi
    done 

} | whiptail --title 'KM2.0 Setup' --gauge "Installing essentials..." 6 50 0
