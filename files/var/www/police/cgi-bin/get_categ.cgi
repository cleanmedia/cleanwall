#!/bin/sh
PATH=/bin:/usr/bin
NS=10.1.1.1
CAT=$(dig +short $HTTP_HOST @$NS | grep wall.lan | awk -F. '{print $(NF-3)}')
DAT=$(date)
echo "Content-type: text/html"
echo
echo "The site <strong>$HTTP_HOST</strong> is in the blocked <strong>$CAT</strong> category."
