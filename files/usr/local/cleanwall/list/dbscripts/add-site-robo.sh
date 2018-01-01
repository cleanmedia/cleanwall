#!/bin/bash
# 24.07.2017 CC BY-SA 4.0 license, Renato Mercurio, Cleanmedia


## VARIABLES
############
PATH='/sbin:/bin:/usr/bin'
CWPATH=/usr/local/cleanwall
SITE=$1
CATEG=$2
MSTAMP=$(date +"%Y%m%d%H%M")

cd ${CWPATH}/list/

# remove eventual leading www.
SITE=${SITE#www.}

LEVEL=$(( $(echo "$SITE" | tr -cd '.' | wc -c ) + 1 ))
CATID=$( sqlite3 ${CWPATH}/list/cmlist.db "select Id from Category where Name = '$CATEG';" )
ID=$(($(./dbscripts/get-maxid.sh) + 1))
ACTION="INSERT INTO Domain (Id, Name, Level, Sourceid, CategoryName, CatId, Invariance) VALUES ($ID, '$SITE', $LEVEL, 2, '$CATEG', $CATID, 5);"

sqlite3 cmlist.db "$ACTION"
echo "${MSTAMP}: $ACTION" >> transaction.log

cd -
