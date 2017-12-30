#### Wireless Client Snippets

Wireless client configuration is optionally needed during installation only and is part of the debian installer now - so we remove this from the main installation instructions. It is interesting for other debian based systems.

```
# ip a
# iwconfig
# ip link set wlan0 up
sudo iwlist scan

vim /etc/network/interfaces
:
# my wifi device
auto wlan0
iface wlan0 inet dhcp
wireless-essid [ESSID]
wireless-mode [MODE]
OR http://www.cyberciti.biz/faq/howto-ubuntu-debian-squeeze-dhcp-server-setup-tutorial/
wpa-ssid myssid
wpa-psk ccb290fd4fe6b22935cbae31449e050edd02ad44627b16ce0151668f5f53c01b

iface wlan_home inet dhcp
wpa-ssid mynetworkname
wpa-psk mysecretpassphrase
```


#### Bridge wlan0 to LAN

Problem:
Most APs did not pass traffic from wired interfaces, if their source hw address did not pre-authenticate with them.
So we must fool the AP in thinking, the packet comes from their own port using ebtables.

Add (under br0):
```
pre-up iwconfig wlan0 essid $YOUR_ESSID
bridge_hw $MAC_ADDRESS_OF_YOUR_WIRELESS_CARD # ip link show wlan0
```


So the Layer 2 Bridge would be as that:
```
apt-get install bridge-utils
bridge_ports enp2s0 enp3s0 enp4s0 wlan0 in interfaces file
```

Ebtables:
```
aptitude install ebtables
# set the source MAC address to the MAC address of the bridge for all frames sent to the AP:
ebtables -t nat -A POSTROUTING -o wlan0 -j snat --to-src $MAC_OF_BRIDGE --snat-arp --snat-target ACCEPT
# the other way round requires us to know each computer and its IP and MAC behind the bridge:
ebtables -t nat -A PREROUTING -p IPv4 -i wlan0 --ip-dst $IP -j dnat --to-dst $MAC --dnat-target ACCEPT
ebtables -t nat -A PREROUTING -p ARP -i wlan0 --arp-ip-dst $IP -j dnat --to-dst $MAC --dnat-target ACCEPT
EBTABLES_ATOMIC_FILE=/root/ebtables-atomic ebtables -t nat --atomic-save # save rules
EBTABLES_ATOMIC_FILE=/root/ebtables-atomic ebtables -t nat --atomic-commit # restore rules
/etc/rc.local (before exit 0) could be the place for this load
```

=> need to know all clients before they have their DHCP IPs
=> So we need another method - proxy ARP:

ProxyARP (layer 3 bridge):
```
echo 1 > /proc/sys/net/ipv4/conf/all/proxy_arp
#ip ro add 10.42.0.11/32 dev enp1s0
=> DHCP is a layer 2 protocol and can't traverse the layer 3 bridge
=> dhcp-helper needed (listen for dhcp req from inside and relay them to dhcp server on outside net)
=> eventually add a /32 route for the net
for mDNS needs avahi-daemon
```

alternatively (to kernel proxy arp plus routing entry) use parprouted

Conclusion:
We try to avoid ebtables and beleive, that linux bridge utils are ready for firewall usage.
