#!/bin/bash
# 24.05.2017 CC BY-SA 4.0 license, Renato Mercurio, Cleanmedia

## VARIABLES
############
LIST=$1
PATH='/sbin:/bin:/usr/bin'
CWPATH=/usr/local/cleanwall

#
cat $LIST |
while read site ; do
  printf "%s " $site
  ${CWPATH}/list/bin/categorize.sh $site
done >${LIST}.categ

cat ${LIST}.categ | grep ' none$' | awk '{print $1}' > ${LIST}.categ.none

