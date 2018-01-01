CWPATH=/usr/local/cleanwall

cd ${CWPATH}/list
sqlite3 ${CWPATH}/list/cmlist.db 'select max(id) from domain;'
