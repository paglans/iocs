# Introduction

This directory contains a files for a series of iocs

## Assumptions
- A linux system (Debian or Ubuntu) set up according to the 'How to Set Up a Soft IOC Framework on Linux' section in the EPICS manual.

##
- copy the softIOC to /etc/init.d/
- copy the configuration file (softiocs.<host>) to somewhere, for example /opt/epics/iocs/
- edit the softIOC init.d script so that the CONFFILE variable point to the configuration file in the previous point.

## To only check out one folder:
```
    mkdir <repo>
    cd <repo>
    git init
    git remote add -f origin <url>
```
This creates an empty repository with your remote, and fetches all objects but doesn't check them out. Then do:

```
    git config core.sparseCheckout true
```
Now you need to define which files/folders you want to actually check out. This is done by listing them in .git/info/sparse-checkout, eg:
```
    echo "some/dir/" >> .git/info/sparse-checkout
    echo "another/sub/tree" >> .git/info/sparse-checkout
```
Last but not least, update your empty repo with the state from the remote:
```
    git pull origin main
```
##
- edit the value of CAMERA_APP in configure/RELEASE
- edit name
- edit IP address
- edit .template(?)

## caRepeater
Make sure a caRepeater is running before starting iocs. Example:
```
    mkdir -p ~/.config/systemd/user
    cat > ~/.config/systemd/user/caRepeater.service << 'EOF'
    [Unit]
    Description=EPICS Channel Access Repeater
    After=network.target

    [Service]
    Type=simple
    ExecStart=/opt/epics/base/bin/linux-x86_64/caRepeater
    Restart=on-failure
    RestartSec=5
    Environment="EPICS_CA_ADDR_LIST=xxx.xxx.xxx.xxx"
    Environment="EPICS_CA_AUTO_ADDR_LIST=NO"
    Environment="EPICS_HOST_ARCH=linux-x86_64"
    Environment="EPICS_BASE=/opt/epics/base"

    [Install]
    WantedBy=default.target
```
Enable and start:
```
    systemctl --user enable caRepeater
    systemctl --user start caRepeater
    systemctl --user status caRepeater
```
To have it run before logging in and any iocs are started:
```
    loginctl enable-linger <user>
```


## manage-iocs
https://github.com/NSLS2/systemd-softioc
