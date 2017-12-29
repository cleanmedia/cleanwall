
cat /var/lib/dhcp/dhcpd.leases | egrep '(^lease |^  starts |^  ends |^  cltt |^  hardware|^  client-hostname)' | tr -d '{;' | perl -p -e 's/^([^ ][^ ].*)$/\t\1/g' | tr -d '\n' | tr '\t' '\n' > /tmp/leases.flat

cat /tmp/leases.flat | awk '{print $19}' | sort | uniq | grep -v '^$' | tr -d '"' > /tmp/clients

cat /tmp/clients |
while read line ; do
  LAST=$(grep "$line" /tmp/leases.flat | tail -1)
  MAC=$(echo $LAST | awk '{print $17}')
  IP=$(echo $LAST | awk '{print $2}')
  printf "%-30s %15s %17s\n" "$line" $IP $MAC
done

