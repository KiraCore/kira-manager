# kira-manager
KIRA Infrastructure Deployment &amp; Monitoring Manager

### Setup instructions:
```
mkdir -p $HOME/tmp && cd $HOME/tmp && wget https://github.com/KiraCore/kira-manager/blob/feature/init_shell/scripts/init.sh -O ./i.sh &>/dev/null && clear && \
 chmod 555 -v ./i.sh &>/dev/null && H="$(sha256sum ./i.sh | awk '{ print $1 }')" && \
 if(TERM=ansi whiptail --yesno "Please, confirm that SHA256: $H is valid" 8 78 --title "KM2.0 Setup"); then ./i.sh ; else clear; echo "INFO: Setup was cancelled by the user."; exit 1; fi
```
