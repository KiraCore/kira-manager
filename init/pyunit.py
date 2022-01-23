import sys
import os
from shutil import copyfile

def createUnit() -> None:
    with open("restserver.service", "w") as u:
        for (k,v) in UNIT.items():
            u.writelines([f"{k}\n"])
            for raw in v:
                u.writelines([f"{raw}={v[raw]}\n"])
def copyUnit() -> None:
    copyfile("restserver.service", "/etc/systemd/system/restserver.service" )

def main():
    user = os.getlogin()

    UNIT ={
        "[Unit]":{"Description":"Restserver", "After":"network.target"},
        "[Service]":{"Type":"simple","User":user,"WorkingDirectory":f"/home/{user}/tmp/kira-manager","ExecStart":"/usr/local/bin/restserver","Restart":"always","RestartSec":"5","LimitNOFILE":"4096"},
        "[Install]":{"WantedBy":"default.target"}
    }
    
    createUnit()
    copyUnit()

if __name__ == "__main__":
    main()