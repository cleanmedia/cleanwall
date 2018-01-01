#!/bin/bash
# 24.05.2017 CC BY-SA 4.0 license, Renato Mercurio, Cleanmedia


## VARIABLES
############
PATH='/sbin:/bin:/usr/bin'
CWPATH=/usr/local/cleanwall
TALOG=transaction.log
SITE=$1
MSTAMP=$(date +"%Y%m%d%H%M")

cd ${CWPATH}/list/

OLD=$( sqlite3 cmlist.db "SELECT * FROM domain WHERE name='$SITE';" )
if [ "$OLD" = "" ]; then
  echo "No need to delete $SITEA !"
else
  # show old entry in transaction log:
  echo "OLD: ${MSTAMP}: $OLD" >> $TALOG

  # now remove the entry:
  ACTION="DELETE FROM domain WHERE name='$SITE';"
  sqlite3 cmlist.db "$ACTION"
  echo "${MSTAMP}: $ACTION" >> $TALOG
fi

cd -
