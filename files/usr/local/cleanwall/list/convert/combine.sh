#!/bin/bash
# 26.05.2017 CC BY-SA 4.0 license, Renato Mercurio, Cleanmedia


## VARIABLES
############
PATH='/sbin:/bin:/usr/bin'
CWPATH=/usr/local/cleanwall

# init
cd ${CWPATH}/list

# get cleanwall categories:

for list in $(cat cw/list | grep -v '^adult' | grep -v pornography) ; do
  cat cw/cw.${list} |
  while read line ; do
    echo ",${line},,1,${list},,," 
  done
done

# get adult category from ut1:
cat ut1/dest/adult/domains |
while read line ; do
  echo ",${line},,3,adult,,,"
done

