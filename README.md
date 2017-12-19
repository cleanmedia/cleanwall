# Cleanwall

debian based content filtering firewall


# Getting the Box

This software should work on any debian based system. However we only support one single hardware platform in this project.

Fully tested and functional contributions for other reasonable platforms however are welcome.

We get the box here:
https://www.aliexpress.com/store/product/QOTOM-Mini-PC-Q190G4-with-4-LAN-port-using-pfsense-as-small-router-firewall-fanless-PC/108231_1000001826190.html

Don't try to order the box, Wifi or SSD from another provider - safe time here first - not money.

**Attention:**

THIS IS AN EARLY DRAFT DOCUMENTATION  - DONT BUY HARDWARE IN THE HOPE THIS WILL WORK EXACTLY AS SHOWN


## Install Debian Server

To give a background of what is being done here, we basically follow this tutorial:

https://www.howtoforge.com/tutorial/debian-minimal-server/

But we download this latest image:

http://cdimage.debian.org/cdimage/unofficial/non-free/cd-including-firmware/9.3.0+nonfree/amd64/iso-cd/firmware-9.3.0-amd64-netinst.iso

And burn it to an USB stick (double check first, if /dev/sdc is right for you):

```
dd if=/home/user/Downloads/firmware-9.3.0-amd64-netinst.iso of=/dev/sdc bs=4M status=progress; sync
```

Boot from the installation stick:

* Attach USB keyboard
* Attach USB stick (burned before)
* Attach VGA monitor
* Attach power
* Push power button and then ESC to enter the BIOS
   * make BIOS and grub boot settings visible
   * keep secure boot enabled
   * choose boot order to enable USB first
   * do not bother too much about network settings (they will be completely overwritten by the firewall installation procedure)
* Boot
* Choose "Install" to use the text based installer
* Follow more or less the mentioned tutorial with the following exceptions:
   * Choose your keyboard, location and language, that suites your needs.
   * choose cleanwall as the hostname



First boot:

* Login as user administrator and the password you gave before.

* eventually you may want to reconfigure locales and the keyboard:
```
sudo dpkg-reconfigure locales
sudo dpkg-reconfigure tzdata
```

* Get ready for ansible deployments:

```
sudo -i
apt-get install ssh openssh-server
apt-get install vim
```

* Enable Time:

```
systemctl enable systemd-timesyncd.service
systemctl start systemd-timesyncd.service
```


# Install Debian Firewall

#### /etc/hosts
```
127.0.0.1 localhost
10.1.1.1 cleanwall.lan cleanwall

# The following lines are desirable for IPv6 capable hosts
#::1 localhost ip6-localhost ip6-loopback
#ff02::1 ip6-allnodes
#ff02::2 ip6-allrouters
```

#### /etc/hostname
```
cleanwall
```
Reboot anc check:

```
reboot
hostname
hostname -f
```

#### /etc/apt/sources.list
This is old and shouldn't be needed:

```
# deb cdrom:[Debian GNU/Linux 8.5.0 _Jessie_ - Official amd64 NETINST Binary-1 20160604-15:31]/ jessie contrib main non-free

deb http://debian.ethz.ch/debian/ jessie main non-free contrib
deb-src http://debian.ethz.ch/debian/ jessie main non-free contrib

deb http://security.debian.org/ jessie/updates main contrib non-free
deb-src http://security.debian.org/ jessie/updates main contrib non-free

# jessie-updates, previously known as 'volatile'
deb http://debian.ethz.ch/debian/ jessie-updates main contrib non-free
deb-src http://debian.ethz.ch/debian/ jessie-updates main contrib non-free
```

#### Update debian

```
apt-get update
apt-get upgrade
```


#### Default Shell
The default 'dash' should be the right choice here. 
Switch back, if you have choosen another one:

```
dpkg-reconfigure dash
```


#### Time
This was not needed:
```
apt-get install ntp ntpdate
```


#### PKI
Install authorized key
```
/root/.ssh/authorized_keys
```


### Network
(minimal install was all dhcp)


#### /etc/sysctl.conf

Sorry for disabling IPv6, but it is still not ready for the end user experience.
I hope to enable that soon. And we acknowledge, that many cool features are waiting for it in the future.

```
# Turn Off IPv6
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
net.ipv6.conf.eth0.disable_ipv6 = 1
net.ipv6.conf.eth1.disable_ipv6 = 1
net.ipv6.conf.eth2.disable_ipv6 = 1
net.ipv6.conf.eth3.disable_ipv6 = 1
net.ipv6.conf.br0.disable_ipv6 = 1
net.ipv6.conf.wlan0.disable_ipv6 = 1
```

Still got IPv6 ... ADDRCONF ... link eth0 is not ready

Enable IPv4 Forwarding:
```
[net.ipv4.ip_forward = 1]
```

Better in a script to avoid remote DHCP on boot:
```
echo 1 > /proc/sys/net/ipv4/ip_forward
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
bridge_ports eth1 eth2 eth3 wlan0 in interfaces file
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
#ip ro add 10.42.0.11/32 dev eth0
=> DHCP is a layer 2 protocol and can't traverse the layer 3 bridge
=> dhcp-helper needed (listen for dhcp req from inside and relay them to dhcp server on outside net)
=> eventually add a /32 route for the net
for mDNS needs avahi-daemon
```

alternatively (to kernel proxy arp plus routing entry) use parprouted

Conclusion:
We try to avoid ebtables and beleive, that linux bridge utils (below) are ready for firewall usage.


#### /etc/network/interfaces
```
source /etc/network/interfaces.d/*

# loopback interface
auto lo
iface lo inet loopback

######################################################################
# Cleanwall Settings

# Activate iptables ipv4 rules
iptables-restore < /etc/iptables.rules

# The external IPv4 WAN interface (eth0)
allow-hotplug eth0
iface eth0 inet dhcp

# The internal IPv4 LAN interface (bridge br0 or eth1)
iface eth1 inet manual
iface eth2 inet manual
iface eth3 inet manual
[iface wlan0 inet manual]

auto br0
iface br0 inet static
bridge_ports eth1 eth2 eth3 [wlan0]
address 10.1.1.1
netmask 255.255.255.0
# dns-nameservers 10.1.1.1 8.8.8.8
```



#### Configure iptables Firewall

See File: 
```
/usr/local/cleanwall/fw/readme.txt
```

```
apt-get install iptables-persistent
```
Snippets of that readme:
```
/usr/local/cleanwall/fw/fw.rules.v4.sh

# iptables-save > /etc/iptables/rules.v4
# iptables-restore < /etc/iptables/rules.v4
```


### Wireless AP

```
apt-get install wireless-tools # + configure
apt-get install lshw
[apt-get install wpasupplicant # WPA2 secured STA]
apt-get install hostapd # AP
```

#### /etc/default/hostapd
```
DAEMON_CONF="/etc/hostapd/hostapd.conf"
```

#### /etc/hostapd/hostapd.conf
```
ctrl_interface=/var/run/hostapd
###############################
# Basic Config
###############################
macaddr_acl=0
# Most modern wireless drivers in the kernel need driver=nl80211
driver=nl80211
##########################
# Local configuration...
##########################
bridge=br0
# the interface used by the AP
interface=wlan0
# a simply means 5GHz (g for 2.4GHz)
hw_mode=g
# the channel to use, 0 means the AP will search for the channel with the least interferences
channel=0
# limit the frequencies used to those allowed in the country
ieee80211d=1
country_code=CH
# 802.11n support
ieee80211n=1
# 802.11ac support
ieee80211ac=1
# QoS support
wmm_enabled=1
# the name of the AP
ssid=CLEANLAN24
# 1=wpa, 2=wep, 3=both
auth_algs=1
# WPA2 only
wpa=2
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
wpa_passphrase=cleanwall6
## Shared Key Authentication ##
auth_algs=1
## Accept all MAC address ###
macaddr_acl=0
```

Restart:
```
systemctl restart hostapd
```

Debug:
```
# hostapd -d /etc/hostapd/hostapd.conf
# tail -f /var/log/syslog
# tcpdump -n port 67 or port 68 # dhcpd relay
# /sbin/iptables -L -n -v | less
# ifconfig br0
# ifconfig | grep H
# brctl show
# brctl showmacs br0
# watch -n 1 cat /proc/net/wireless
# wavemon
```


#### /etc/network/interfaces
```
iface wlan0 inet manual
or like so

iface br0 inet dhcp
bridge_ports wlan0 eth0 eth1 eth2 eth3
bridge_stp off
bridge_waitport 5
bridge_fd 0
pre-up iw dev wlan0 set 4addr on
post-down iw dev wlan0 set 4addr off
```


Wireless Client Snippets:
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


#### DHCP Server
```
apt-get install isc-dhcp-server
```

We follow:
http://www.cyberciti.biz/faq/howto-ubuntu-debian-squeeze-dhcp-server-setup-tutorial/

And more or less this:
https://wiki.debian.org/de/DHCP_Server: 

```
vim /etc/dhcp/dhcpd.conf
```

Snippets:

```
option domain-name "soho.lan";
option domain-name-servers 8.8.8.8, 8.8.4.4;
option domain-name-servers 10.1.1.1, 8.8.8.8;
subnet 192.168.10.0 netmask 255.255.255.0 {
       range 192.168.10.100 192.168.10.199;
       option routers 192.168.10.1;
}
```

```
/etc/init.d/isc-dhcp-server start
/etc/default/isc_dhcp_server
```

Make the DHCP server listen on LAN only and not broadcast requests to the WAN!
```
INTERFACES br0
```


#### Mail
```
/etc/exim4/update-exim4.conf.conf
# without ipv6 localloop ::1 listen port
rm /var/log/exim4/paniclog
```



# Install Content Filtering Engine

TODO
