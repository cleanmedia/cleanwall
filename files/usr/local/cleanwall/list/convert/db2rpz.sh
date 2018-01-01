#!/bin/bash
# 26.05.2017 CC BY-SA 4.0 license, Renato Mercurio, Cleanmedia


## VARIABLES
############
PATH='/sbin:/bin:/usr/bin'
LISTPATH=/usr/local/cleanwall/list
SER=$(date +"%Y%m%d%H")
BLACKRPZ=${LISTPATH}/convert/data/db.rpz.black
rm -f $BLACKRPZ

SEDSTR="s/[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]/${SER}/g"

# set dates hour as new serial in head:
sed -i "${SEDSTR}" ${LISTPATH}/convert/data/db.rpz.head

# extract one file per black category:
for categ in $(cat ${LISTPATH}/blackcateg) ; do
  ${LISTPATH}/dbscripts/get-names.sh $categ > ${LISTPATH}/convert/data/db.${categ}.li
  
echo "" >> ${BLACKRPZ}
echo ";-------------------------------------------------------------------" >> ${BLACKRPZ}
echo "; $categ sites blocked due to choosen usage policy" >> ${BLACKRPZ}
echo ";-------------------------------------------------------------------" >> ${BLACKRPZ}

cat ${LISTPATH}/convert/data/db.${categ}.li | ${LISTPATH}/convert/bdomains2rpz.pl | sed "s/wall\.lan/${categ}\.wall\.lan/g" >> ${BLACKRPZ}

  echo "DONE $categ"
done


### put together
cat ${LISTPATH}/convert/data/db.rpz.head ${BLACKRPZ} > ${LISTPATH}/convert/data/db.rpz


# copy to bind
# bzip2 /etc/bind/db.rpz
# mv /etc/bind/db.rpz.bz2 /etc/bind/db.rpz.20170611.bz2
# mv ${LISTPATH}/convert/data/db.rpz /etc/bind/


