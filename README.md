# kira-manager
KIRA Infrastructure Deployment &amp; Monitoring Manager

### Setup instructions:
```
sudo -s

cd /tmp && read BRANCH=$(whiptail --inputbox "Please, enter chain id" 8 78 master --title "KM2.0 Setup" 3>&1 1>&2 2>&3) && \
 wget https://github.com/KiraCore/kira-manager/tree/feature/init_shell/inist.sh -O ./i.sh && \
 chmod 555 -v ./i.sh && H=$(sha256sum ./i.sh | awk '{ print $1 }') && SHA = $(whiptail --yesno "Please, confirm that SHA256: $H is valid" 8 78 master --title "KM2.0 Setup") && echo "INFO: Setup was cancelled by the user." || ./i.sh "$BRANCH"
```
