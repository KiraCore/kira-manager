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

installEssentials () {
    for (( i=0; i<${ESSENTIALS_LEN}; i++ )) ; do
        COUNTER=$((100/$ESSENTIALS_LEN*$i)) 
        echo -e "XXX\n$COUNTER\n${ESSENTIALS_OPERATIONS[$i]}\nXXX"
        echo "${ESSENTIALS[$i]}" 1>>log 2>>log
        eval $(echo "${ESSENTIALS[$i]}") 1>>log 2>>log 
        err=$?
        [[ $err != 0 ]] && whiptail --title "KM2.0 Setup" --msgbox "Installation of essentials faield..." 10 60 && exit 1
    done
}


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
    exit 1 
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
ESSENTIALS_OPERATIONS[5]="Installing python 3.10.0..."
ESSENTIALS_OPERATIONS[6]="Installing pip3..."
ESSENTIALS_OPERATIONS[7]="Clonning repo..."
ESSENTIALS_OPERATIONS[8]="Configuring KM2.0..."
ESSENTIALS_OPERATIONS[9]="Creating symlink..."
ESSENTIALS_OPERATIONS[10]="Updating daemon..."
ESSENTIALS_OPERATIONS[11]="Enabling daemon..."
ESSENTIALS_OPERATIONS[12]="Starting rest server..."


declare -A ESSENTIALS
ESSENTIALS[0]="sudo -S <<< \"$PSWD\" apt-get update -y >> log"
ESSENTIALS[1]="wget https://dl.google.com/go/go$GO_VERSION.linux-$GOLANG_ARCH.tar.gz >> log" 
ESSENTIALS[2]="sudo -S <<< \"$PSWD\" tar -C /usr/local -xvf go$GO_VERSION.linux-$GOLANG_ARCH.tar.gz >> log"
ESSENTIALS[3]="sudo -S <<< \"$PSWD\" apt-get install git -y >> log"
ESSENTIALS[4]="sudo -S <<< \"$PSWD\" apt-get install build-essential -y >> log"
ESSENTIALS[5]="sudo -S <<< \"$PSWD\" sudo apt install python3"
ESSENTIALS[6]="sudo -S <<< \"$PSWD\" sudo apt -y install python3-pip"
ESSENTIALS[7]="git clone https://github.com/KiraCore/kira-manager.git >> log"
ESSENTIALS[8]="cd $HOME/tmp/kira-manager && git checkout origin/feature/pkgcheck >> ../log && make >> ../log && make init >> ../log"
ESSENTIALS[9]="sudo -S <<< \"$PSWD\" cp restserver /usr/local/bin && sudo chown '$WHOAMI:$WHOAMI /usr/local/bin/'"
ESSENTIALS[10]="sudo -S <<< \"$PSWD\" systemctl daemon-reload"
ESSENTIALS[11]="sudo -S <<< \"$PSWD\" systemctl enable restserver.service"
ESSENTIALS[12]="sudo -S <<< \"$PSWD\" systemctl start restserver.service"

ESSENTIALS_LEN=${#ESSENTIALS[@]}

installEssentials | whiptail --title 'KM2.0 Setup' --gauge "Installing essentials..." 6 50 0
whiptail --title "KM2.0 Setup" --msgbox "Installation completed" 10 60 && clear
