# Introduction

This directory contains a files for a series of iocs

## Assumptions
- A linux system (Debian or Ubuntu) set up according to the 'How to Set Up a Soft IOC Framework on Linux' section in the EPICS manual.

##
- copy the softIOC to /etc/init.d/
- copy the configuration file (softiocs.<host>) to somewhere, for example /opt/epics/iocs/
- edit the softIOC init.d script so that the CONFFILE variable point to the configuration file in the previous point.
