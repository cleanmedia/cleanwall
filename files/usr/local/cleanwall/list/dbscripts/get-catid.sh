CWPATH=/usr/local/cleanwall
sqlite3 ${CWPATH}/cmlist.db "select id from category where name='$1';"
