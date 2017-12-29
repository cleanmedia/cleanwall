Create Current Client List
==========================
mkdir /var/log/cleanwall

cat /var/lib/dhcp/dhcpd.leases | grep hardware | awk '{print $3}' | sort | uniq | tr -d ';'
cat /var/lib/dhcp/dhcpd.leases | grep client-hostname | awk '{print $2}' | sort | uniq | tr -d '[";]'

Transform the lease file:
cat /var/lib/dhcp/dhcpd.leases | egrep '(^lease |^  starts |^  ends |^  cltt |^  hardware|^  client-hostname)' | tr -d '{;' | perl -p -e 's/^([^ ][^ ].*)$/\t\1/g' | tr -d '\n' | tr '\t' '\n' > /tmp/leases.flat
cat /tmp/leases.flat | awk '{print $19}' | sort | uniq | grep -v '^$' | tr -d '"' > /tmp/clients
rm -f /tmp/clientlist
cat /tmp/clients |
while read line ; do
  LAST=$(grep "$line" /tmp/leases.flat | tail -1)
  MAC=$(echo $LAST | awk '{print $17}')
  IP=$(echo $LAST | awk '{print $2}')
  echo "\"$line\" $IP $MAC" >> /tmp/clientlist
done


Time Filter
===========
iptables mac module: 
-m mac --mac-source e8:94:f6:33:73:9b 
iptables time module:
-m time --timestart 23:00 --timestop 04:00 --weekdays Mon,Tue,Wed,Thu,Fri,Sat,Sun
will restrict Internet web access from 23:00 UTC until 04:00 (00:00 till 05:00 CET)


MAC Vendor List
===============
curl -o oui.txt http://standards-oui.ieee.org/oui.txt
#curl -o oui.txt.bz2 http://linuxnet.ca/ieee/oui.txt.bz2
#bunzip2 oui.txt.bz2
grep E0F5C6 oui.txt | awk -F'\t' '{print $3}'

