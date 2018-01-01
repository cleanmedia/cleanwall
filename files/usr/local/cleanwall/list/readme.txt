CREATE SQLITE DB
================
apt-get install sqlite3

sqlite3 cmlist.db < create-tables.sql
sqlite3 cmlist.db < insert-category.sql
sqlite3 cmlist.db < insert-source.sql


IMPORT HISTORY
==============
cd /usr/local/cleanwall/list
# ./rpz2sql.sh
# takes more than 3h:
# sqlite3 cmlist.db < insert-rpz.sql

# alternative bulk import:
./combine.sh | nl -nln > full.imp
sqlite3 cmlist.db
.separator ','
.import  full.imp Domain

.timeout 1000

# set level
update Domain set level = (select length(Name) - length(replace(Name, '.', '')) + 1);

# add catid of these
update Domain set CatId = (select Id from Category where Name = Domain.CategoryName);

# fix ut1 false positive:
delete from domain where id=(select id from domain where name='sexaa.org' and categoryname='adult');
delete from domain where id=(select id from domain where name='pornsunday.com' and categoryname='adult');
delete from domain where id=(select id from domain where name='porno-frei.ch' and categoryname='adult');


# import top100
sqlite3 cmlist.db
.separator ','
.import top100list.csv Domain
.import exceptions.imp.csv Domain
.import vip.list Domain

#add catid to manual entries:
update Domain set CatId = (select Id from Category where Name = Domain.CategoryName) where SourceId=4;

# set level also here:
update Domain set level = (select length(Name) - length(replace(Name, '.', '')) + 1) where SourceId=4;


convert UT1 category for import (each separately):
./ut2imp.sh ads Ads
./ut2imp.sh bank Finance
./ut2imp.sh blog Blogging
./ut2imp.sh chat Messaging
./ut2imp.sh cleaning Computer
./ut2imp.sh dangerous_material Weapons
./ut2imp.sh dating Dating
./ut2imp.sh drogue Drugs
./ut2imp.sh filehosting Filehosting
./ut2imp.sh financial Finance
./ut2imp.sh gambling Gambling
./ut2imp.sh games Games
./ut2imp.sh hacking Malware
./ut2imp.sh jobsearch Jobs
./ut2imp.sh malware Malware
./ut2imp.sh mixed_adult Mixedadult
./ut2imp.sh phishing Phishing
./ut2imp.sh press News
./ut2imp.sh radio Radio
./ut2imp.sh redirector Redirector
./ut2imp.sh remote-control Remote
./ut2imp.sh sect Sect
./ut2imp.sh shopping Shopping
./ut2imp.sh shortener Shortener
./ut2imp.sh social_networks Social
./ut2imp.sh sports Sports
./ut2imp.sh translation Directories
./ut2imp.sh warez Illegal
./ut2imp.sh webmail Webmail


tumblr
======
sqlite3 ${CWPATH}/list/cmlist.db
delete from domain where name like '%tumblr.com' and sourceid=3;


CATEGORY CHECK
==============
./bin/categorize.sh glamourmagazine.co.uk
./bin/bulk-categorize.sh domlist
-> domlist.categ & domlist.categ.none


KNOWN CATEGORY IMPORT
=====================
./new2imp.sh health.new Health  # -> health.new.imp
und dann health.new.imp wie oben top100

./new2imp.sh phishing.new.none Phishing
./new2imp.sh search.new.categ.none Search
./new2imp.sh computer.new.categ.none Computer
./new2imp.sh health.new.categ.none Health


Add Single Site
===============
(directly to category in db)
./add-site.sh wikimedia.org Directories
./add-site.sh googleapis.com Computer
./add-site.sh gstatic.com Computer
./add-site.sh googlesyndication.com Ads
./add-site.sh googlevideo.com Video
./add-site.sh victoriassecret.com Shopping
./add-site.sh whatsapp.net Messaging
./add-site.sh nflxvideo.net Video
./add-site.sh akamaiedge.net Computer
./add-site.sh cloudfront.net Computer
./add-site.sh icloud.com Computer
./add-site.sh wolframalpha.com Search
./add-site.sh google-analytics.com Ads
./add-site.sh windows.com Computer
./add-site.sh skype.net Computer
./add-site.sh rackcdn.com Computer
./add-site.sh alicdn.com Computer
./add-site.sh mzstatic.com Computer
./add-site.sh akamai.net Computer
...
./add-site.sh cloudflare.net Computer
./add-site.sh netdna-cdn.com Computer
./add-site.sh fungames-forfree.com Games
./add-site.sh nation.co.ke News
./add-site.sh incapdns.net Computer
./add-site.sh newsprints.co.uk News
./add-site.sh fastly.net Computer
./add-site.sh harward.edu Education
./add-site.sh businessinsider.com News
./add-site.sh bbcimg.co.uk News
./add-site.sh cdn77.org Ads
./add-site.sh tastemade.com News
./add-site.sh dynect.net Computer
./add-site.sh loversiq.com News
./add-site.sh crashlytics.com Computer
./add-site.sh consoliads.com Computer
./add-site.sh metro.co.uk News
./add-site.sh netdna-ssl.com Computer
...


DB2RPZ
======

cd convert
./db2rpz.sh
bzip2 /etc/bind/db.rpz
mv data/db.rpz /etc/bind/
named-checkzone rpz /etc/bind/db.rpz
systemctl restart bind9.service
bind needs up to 2 minutes, to recover and answer requests again

