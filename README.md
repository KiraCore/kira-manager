# kira-manager
KIRA Infrastructure Deployment &amp; Monitoring Manager

### Setup instructions:
```
sudo -s

cd /tmp && BRANCH="$(TERM=ansi whiptail --inputbox 'Please, enter chain id' 8 78 master --title 'KM2.0 Setup' 3>&1 1>&2 2>&3)" && \
 wget https://github.com/KiraCore/kira-manager/tree/feature/init_shell/init.sh -O ./i.sh &>/dev/null && clear && \
 chmod 555 -v ./i.sh &>/dev/null && H="$(sha256sum ./i.sh | awk '{ print $1 }')" && \
 SHA="$(TERM=vt220 whiptail --yesno 'Please, confirm that SHA256: $H is valid' 8 78 --title 'KM2.0 Setup' --clear)" && \
 echo "INFO: Setup was cancelled by the user." || ./i.sh 
```
