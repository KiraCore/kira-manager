#!/bin/bash

#To avoid password leakage
export HISTIGNORE='*sudo -S*'

WHOAMI="$(whoami)"
if [[ $WHOAMI == "root" ]]; then
    whiptail --title "KM2.0 Setup" --msgbox "Plesase create a sudo user first. You can't proceed as root." 10 60
    exit 1
fi

export GO_VERSION="1.15.11"
export GOROOT="/usr/local/go"
export GOPATH="/home/go"
export GOCACHE="/home/go/cache"
export GOBIN="${GOROOT}/bin"
export GO="${GOBIN}/go"
ARCHITECTURE=$(uname -m)


if [[ "${ARCHITECTURE,,}" == *"arm"* ]] || [[ "${ARCHITECTURE,,}" == *"aarch"* ]] ; then
   export GOLANG_ARCH="arm64"
else
   export GOLANG_ARCH="amd64"
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
ESSENTIALS_OPERATIONS[3]="Installing git..."
ESSENTIALS_OPERATIONS[4]="Installing build_essential..."
ESSENTIALS_OPERATIONS[5]="Clonning repo..."
ESSENTIALS_OPERATIONS[6]="Configuring KM2.0..."

declare -A ESSENTIALS
ESSENTIALS[0]="sudo -S <<< \"$PSWD\" apt-get update -y >> log"
ESSENTIALS[1]="wget https://dl.google.com/go/go$GO_VERSION.linux-$GOLANG_ARCH.tar.gz >> log" 
ESSENTIALS[2]="sudo -S <<< \"$PSWD\" tar -C /usr/local -xvf go$GO_VERSION.linux-$GOLANG_ARCH.tar.gz >> log"
ESSENTIALS[3]="sudo -S <<< \"$PSWD\" apt-get install git -y >> log"
ESSENTIALS[4]="sudo -S <<< \"$PSWD\" apt-get install build-essential -y >> log"
ESSENTIALS[5]="sudo -S <<< \"$PSWD\" git clone https://github.com/KiraCore/kira-manager.git"
ESSENTIALS[6]="cd $HOME/tmp/kira-manager && sudo -S <<< \"$PSWD\" git checkout origin/feature/server && sudo -S <<< \"$PSWD\" make"  

ESSENTIALS_LEN=${#ESSENTIALS[@]}

{ 
    for (( i=0; i<${ESSENTIALS_LEN}; i++ )) ; do

        COUNTER=$((100/$ESSENTIALS_LEN*$i)) 
        echo -e "XXX\n$COUNTER\n${ESSENTIALS_OPERATIONS[$i]}\nXXX"
        echo "${ESSENTIALS[$i]}" >> log 
        eval $(echo "${ESSENTIALS[$i]}") &>eval.log
        sudo -S <<< "$PSWD" echo "#########################################################################" >> log
        sudo -S <<< "$PSWD" echo $? >> log
        if [[ $? != 0 ]]; then
            whiptail --title "KM2.0 Setup" --msgbox "Installation of essentials faield..." 10 60
            echo "${ESSENTIALS[$i]}"
            exit 1
        fi
    done 

} | whiptail --title 'KM2.0 Setup' --gauge "Installing essentials..." 6 50 0
clear