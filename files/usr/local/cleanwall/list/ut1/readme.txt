cd /usr/local/cleanwall/list/ut1
rsync -arpogvt rsync://ftp.ut-capitole.fr/blacklist .

grep -v tumblr dest/adult/domains > dest/adult/domains.new
mv dest/adult/domains.new dest/adult/domains

vim dest/mixed_adult/domains
add tumblr.com

