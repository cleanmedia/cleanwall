cat $1 |
while read site ; do
  echo $site
  sqlite3 cmlist.db "delete from domain where name='$site' and categoryname='Adult';"
done
