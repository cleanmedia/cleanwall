#!/bin/bash
# 24.05.2017 CC BY-SA 4.0 license, Renato Mercurio, Cleanmedia


## VARIABLES
############
PATH='/sbin:/bin:/usr/bin'
CWPATH=/usr/local/cleanwall
categ=$1

sqlite3 ${CWPATH}/list/cmlist.db "select Name from Domain where CategoryName='$categ';"

