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
    git pull origin master
```
