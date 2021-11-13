# kira-manager
KIRA Infrastructure Deployment &amp; Monitoring Manager

### Setup instructions:
```
sudo -s

cd /tmp && CHAINID="$(TERM=ansi whiptail --inputbox 'Please, enter existing or new chain id' 8 78 master --title 'KM2.0 Setup' 3>&1 1>&2 2>&3)" && \
 wget https://raw.githubusercontent.com/KiraCore/kira-manager/feature/init_shell/init.sh -O ./i.sh &>/dev/null && clear && \
 chmod 555 -v ./i.sh &>/dev/null && H="$(sha256sum ./i.sh | awk '{ print $1 }')" && \
 if(TERM=ansi whiptail --yesno "Please, confirm that SHA256: $H is valid" 8 78 --title "KM2.0 Setup"); then ./i.sh $CHAINID; else clear; echo "INFO: Setup was cancelled by the user."; exit 1; fi
```
