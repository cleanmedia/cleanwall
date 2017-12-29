#!/bin/bash
# 01.07.2017 CC BY-SA 4.0 license, Renato Mercurio, Cleanmedia

MAC=$1
OUI=/usr/local/cleanwall/fw/mac/oui.txt
MAC2=$(echo $MAC | awk -F: '{print toupper($1)toupper($2)toupper($3)}')
VENDOR=$(grep $MAC2 $OUI | awk -F'\t' '{print $3}' | tr -d '\r')
echo $VENDOR
