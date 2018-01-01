#!/bin/bash
# 24.05.2017 CC BY-SA 4.0 license, Renato Mercurio, Cleanmedia


## VARIABLES
############
PATH='/sbin:/bin:/usr/bin'
CWPATH=/usr/local/cleanwall
dom=$1

categ=$( sqlite3 ${CWPATH}/list/cmlist.db "select CategoryName from Domain where Name = '$dom';" )

if [ "$categ" = "" ]; then
  echo "none"
else
  echo "$categ"
fi

