#### IPv6 snippets
```
/etc/network/interfaces
-----------------------
#auto lo eth0 br0 br6
#allow-hotplug wlan0 eth0 br0 br6

# Setup WAN
iface eth0 inet6 auto

# Setup IPv6 LAN bridge
#iface br6 inet6 auto
# bridge_ports eth0 eth1 eth2 eth3
# accept_ra off oder aehnlich


# IPv6 brige hint:
problem: br0 for v6 breaks v4 (rename br6 better but not good yet)
use separate physical interfaces and avoid IPv6 bridge
sysctl net.ipv6.conf.br0.accept_ra=0


radvd
-----
# RADVD with DHCPd6 configuration
# /etc/radvd.conf
interface br0 {
AdvManagedFlag on;
AdvSendAdvert on;
AdvAutonomous off;
AdvOtherConfigFlag on;
MinRtrAdvInterval 3;
MaxRtrAdvInterval 60;
};

# RADVD with no DHCPd6 configuration
# /etc/radvd.conf
interface br0 {
AdvManagedFlag on;
AdvSendAdvert on;
AdvAutonomous on;
AdvLinkMTU 1480;
AdvOtherConfigFlag on;
MinRtrAdvInterval 3;
MaxRtrAdvInterval 60;
prefix 2001:0db8:edfa:1234::/64 {
AdvOnLink on;
AdvRouterAddr on;
};
};
```


Debug IPv6:
```
apt-get install tcpdump
tcpdump -i eth1 ip6
```
