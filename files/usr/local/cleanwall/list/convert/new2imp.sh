#!/bin/bash
# 26.05.2017 CC BY-SA 4.0 license, Renato Mercurio, Cleanmedia


## VARIABLES
############
PATH='/sbin:/bin:/usr/bin'
CWPATH=/usr/local/cleanwall
INFILE=$1
OUTCAT=$2

# get category from ut1:
cat ${INFILE} |
while read line ; do
  echo ",${line},,3,${OUTCAT},,,,3,"
done > /tmp/new2imp-${INFILE}.csv

cat /tmp/new2imp-${INFILE}.csv | nl -nln -v $(( $(./get-maxid.sh) + 1)) > new2imp-${INFILE}.imp

