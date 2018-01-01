#!/bin/bash
# 09.07.2017 CC BY-SA 4.0 license, Renato Mercurio, Cleanmedia


## VARIABLES
############
PATH='/sbin:/bin:/usr/bin'
CWPATH=/usr/local/cleanwall
DEBUG=1
SITE=$1
CATEG=$2

# check input:
if [ "$CATEG" == "" ] ; then
  echo "Usage: set-categ.sh <domain> <categoryname>"
  echo "Example: set-categ.sh vimeo.com Video"
  exit 1
fi

cd ${CWPATH}/list/

# check if domain exists:
DOMID=$( sqlite3 ${CWPATH}/list/cmlist.db "select Id from Domain where Name = '$SITE';" )
if [ "$DOMID" == "" ] ; then
  echo "The Site $SITE does not exist!"
  exit 1
fi

[ "$DEBUG" = "1" ] && echo "DOMID=$DOMID ..."

# eval catid from categoryname given:
CATID=$( sqlite3 ${CWPATH}/list/cmlist.db "select Id from Category where Name = '$CATEG';" )
if [ "$CATID" == "" ] ; then
  echo "The Category Name $CATEG does not seem to exist!"
  exit 1
fi

[ "$DEBUG" = "1" ] && echo "CATID=$CATID ..."

# finally update the category:
[ "$DEBUG" = "1" ] && echo "executing ..."
[ "$DEBUG" = "1" ] && echo "UPDATE Domain SET CatId=$CATID AND CategoryName='$CATEG' WHERE Id=$DOMID;"

sqlite3 cmlist.db "UPDATE Domain SET CatId=$CATID , CategoryName='$CATEG' WHERE Id=$DOMID;"

cd -
