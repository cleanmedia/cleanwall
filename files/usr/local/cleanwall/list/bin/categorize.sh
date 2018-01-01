#!/bin/bash
# 24.05.2017 CC BY-SA 4.0 license, Renato Mercurio, Cleanmedia


## VARIABLES
############
PATH='/sbin:/bin:/usr/bin'
CWPATH=/usr/local/cleanwall
dom=$1
domL=$dom
#NS=10.1.1.1 # cleanwall.lan
NS=8.8.8.8

function check()
{
  c=$1
  # exit on success:
  if [ "$c" != "none" ]; then
    echo "$c"
    exit
  fi
  return
}

# get bottom level category:
categ=$(${CWPATH}/list/dbscripts/get-categ.sh $dom)
# return category on success:
check $categ

# check if original (uncategorized) site has no public DNS entry:
IP=$(dig +short $dom @$NS | tail -1)
if [ "$IP" = "" ]; then
  echo "nodns"
  exit
fi

function strip-dom()
{
  # remove bottom level domain (from left side until the first dot):
  d=$1
  domL=${d#*.}
  return
}


# count domain levels:
level=$(( $(echo "$dom" | tr -cd '.' | wc -c ) + 1 ))

# if we have only a level one domain, we are already done here:
if [ $level = 1 ]; then
  echo "none"
  exit
fi


# check each level:
for (( i=level; i>1; i-- ))
do
  #remove one bottom level:
  strip-dom $domL
  # get it's category:
  categ=$(${CWPATH}/list/dbscripts/get-categ.sh $domL)
  # break loop on success:
  check $categ
done


# we got here, so the result is none:
echo "none"

