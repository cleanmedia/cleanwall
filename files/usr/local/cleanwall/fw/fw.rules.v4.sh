#!/bin/bash
# 08.07.2017 CC BY-SA 4.0 license, Renato Mercurio, Cleanmedia


## VARIABLES
############
PATH='/sbin:/bin:/usr/bin'
FWPATH=$(dirname $0)
source ${FWPATH}/vars.v4.load


## INIT
#######

# Flush previous rules, delete chains and reset counters
iptables -F
iptables -X
iptables -Z
iptables -t nat -F

echo -n '1' > /proc/sys/net/ipv4/ip_forward
echo -n '0' > /proc/sys/net/ipv4/conf/all/accept_source_route
echo -n '0' > /proc/sys/net/ipv4/conf/all/accept_redirects
#echo -n '1' > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
#echo -n '1' > /proc/sys/net/ipv4/icmp_ignore_bogus_error_responses


## NATCENSOR
############
# send forbidden http(s) ip destinations to sorry
cat ${FWPATH}/etc/forbidden | grep -v '^#' |
while read ip; do
	iptables -t nat -A PREROUTING -p tcp --dport 80 -d $ip -j DNAT --to-destination $SORRY
        iptables -t nat -A PREROUTING -p tcp --dport 443 -d $ip -j DNAT --to-destination $SORRY
done

# allow some src ip direct routing before any redirects
cat ${FWPATH}/etc/allowed | grep -v '^#' |
while read ip; do
	iptables -t nat -A PREROUTING -d $ip -j ACCEPT
done


## INGRESS FILTER
#################

# Keep established WAN conections (after that, only need to allow NEW conections)
iptables -A INPUT   -i $WANIF -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i $WANIF -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow incoming ssh from the WAN side
#iptables -A INPUT -i $WANIF -p tcp --dport 22 -m conntrack --ctstate NEW -j ACCEPT
# Incoming HTTP(S) from the WAN side
#iptables -A INPUT -i $WANIF    -p tcp --dport 80 -m conntrack --ctstate NEW -j ACCEPT
#iptables -A INPUT -i $WANIF    -p tcp --dport 443 -m conntrack --ctstate NEW -j ACCEPT

# drop all other incoming WAN traffic
iptables -A INPUT   -i $WANIF -j DROP
iptables -A FORWARD -i $WANIF -j DROP


## FORCE LOCAL DHCP ONLY
########################
# dont forward DHCP to WAN cascaded Subnets - apparently seems not enaugh
iptables -A FORWARD -i $LANIF -o $WANIF -p udp --dport 67:68 -j REJECT


## POSTROUTING (sNAT)
#####################
# We have dynamic IP (DHCP), so we've to masquerade WAN traffic: 
iptables -t nat -A POSTROUTING -o $WANIF -j MASQUERADE


## ROUTED TRAFFIC INTERCEPTION
##############################

# Time Filter:
${FWPATH}/time.v4

# Control the DNS (force dns resolutions to local cleanwall):
${FWPATH}/dns-redir.v4

# SRC IP Whitelist that still has DNS Control
# it's ok to add this after the sNAT masquerading rule, because POSTROUTING comes later
cat ${FWPATH}/etc/allowed_src | grep -v '^#' |
while read ip; do
        iptables -t nat -A PREROUTING -s $ip -j ACCEPT
done

# transparent web traffic redirection to cleanwall proxy:
${FWPATH}/web-redir.v4


## LOGGING
##########

#iptables -A INPUT   -j LOG --log-level 7 --log-prefix '[FW INPUT]:    '
#iptables -A OUTPUT  -j LOG --log-level 7 --log-prefix '[FW OUTPUT]:   '
#iptables -A FORWARD -j LOG --log-level 7 --log-prefix '[FW FORWARD ]: '
#iptables -t nat -A POSTROUTING -j LOG --log-level 7 --log-prefix '[FW NAT POSTR]: '
#iptables -t nat -A PREROUTING -j LOG --log-level 7 --log-prefix '[FW NAT PRER]:  '


# Add a line like this for each eth* LAN (not neded havin a default accept policy)
##iptables -A FORWARD -i $LANIF -j ACCEPT

