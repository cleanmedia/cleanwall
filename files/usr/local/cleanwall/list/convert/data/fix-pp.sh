DB=/usr/local/cleanwall/list/cmlist.db

cat dual-adu-red.li |
while read line ; do
  sqlite3 $DB "update domain set cat2id=1 where id=(select id from domain where name='$line' and catid=41);"
  sqlite3 $DB "delete from domain where id=(select id from domain where name='$line' and catid=1);"
done
