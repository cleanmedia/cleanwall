#!/bin/bash
# 26.05.2017 CC BY-SA 4.0 license, Renato Mercurio, Cleanmedia


## VARIABLES
############
PATH='/sbin:/bin:/usr/bin'
LISTPATH=/usr/local/cleanwall/list

# fast bulk convert using grep/sed
# remove secondary lines beginning with a star and keep CNAME content only:
cat /etc/bind/db.rpz | egrep -v '^\*\.' | grep CNAME > /tmp/rpz.tmp
# remove leading star characters from category:
cat /tmp/rpz.tmp | sed "s/\*\.//g" > /tmp/rpz2.tmp
# remove rest of unneeded chars:
cat /tmp/rpz2.tmp | sed "s/\.wall\.lan\./'/g" | sed 's/CNAME//g' | sed "s/\t /','/g" | sed "s/^/'/g" > /tmp/rpz3.tmp
# create category list
cat /tmp/rpz3.tmp | awk -F, '{print $2}' | sort | uniq | tr -d "\'" > cw/list
clist=$(cat cw/list)
# extract one file per category:
for categ in $clist ; do
  cat /tmp/rpz3.tmp | grep "${categ}'$" | awk -F, '{print $1}' | tr -d "\'" > cw/cw.${categ}
  echo "DONE $categ"
done

rm /tmp/rpz*.tmp

