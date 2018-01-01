#!/bin/bash
# 26.05.2017 CC BY-SA 4.0 license, Renato Mercurio, Cleanmedia


## VARIABLES
############
PATH='/sbin:/bin:/usr/bin'
CWPATH=/usr/local/cleanwall
INCAT=$1
OUTCAT=$2

# get category from ut1:
cat ut1/dest/${INCAT}/domains |
while read line ; do
  echo ",${line},,3,${OUTCAT},,,,3,"
done > /tmp/ut2imp-${INCAT}.csv

cat /tmp/ut2imp-${INCAT}.csv | nl -nln -v $(( $(./get-maxid.sh) + 1)) > ut2imp-${INCAT}.imp

