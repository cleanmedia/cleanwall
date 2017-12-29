#!/bin/bash

PATH='/sbin:/bin:/usr/bin'
CWPATH=/usr/local/cleanwall
TMPPATH=/tmp/log-leases
MAC2VEN=${CWPATH}/fw/mac/mac2vendor.sh
CLTLIST=/var/log/cleanwall/clientlist
touch $CLTLIST
IPLIST=${CWPATH}/fw/mac/iplist
touch $IPLIST

# register client IPs
cat /var/lib/dhcp/dhcpd.leases | egrep '(^lease |^  starts |^  ends |^  cltt |^  hardware|^  client-hostname)' | tr -d '{;' | perl -p -e 's/^([^ ][^ ].*)$/\t\1/g' | tr -d '\n' | tr '\t' '\n' >> /var/log/cleanwall/leases.flat

${CWPATH}/fw/mac/show-mac.sh > $TMPPATH

cat $TMPPATH |
while read line ; do
  if [ "$(grep "$line" $CLTLIST | wc -l)" != "1" ] ; then
    # this client - ip - mac triplet was not stored before - store:
    echo "$line" >> $CLTLIST
    # update the current ip list:
    mac=$(echo $line | awk '{print $3}')
    grep -v $mac ${IPLIST} > ${IPLIST}.tmp
    vendor=$($MAC2VEN $mac)
    echo "$line $vendor" >> ${IPLIST}.tmp
    mv ${IPLIST}.tmp ${IPLIST}
  fi
done

