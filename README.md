# Cleanwall

debian based content filtering firewall


<p><div class="toc">
<ul>
<li><a href="#getting-the-box">Getting the Box</a></li>
<li><a href="#install-debian-server">Install Debian Server</a></li>
<li><a href="#install-debian-firewall">Install Debian Firewall</a><ul>
<li><ul>
<li><a href="#etchosts">/etc/hosts</a></li>
<li><a href="#etchostname">/etc/hostname</a></li>
<li><a href="#etcaptsourceslist">/etc/apt/sources.list</a></li>
<li><a href="#update-debian">Update debian</a></li>
<li><a href="#default-shell">Default Shell</a></li>
<li><a href="#time">Time</a></li>
<li><a href="#pki">PKI</a></li>
</ul>
</li>
<li><a href="#network">Network</a><ul>
<li><a href="#etcsysctlconf">/etc/sysctl.conf</a></li>
<li><a href="#etcnetworkinterfaces">/etc/network/interfaces</a></li>
<li><a href="#configure-iptables-firewall">Configure iptables Firewall</a></li>
<li><a href="#wireless-ap">Wireless AP</a><ul>
<li><a href="#etcdefaulthostapd">/etc/default/hostapd</a></li>
<li><a href="#etchostapdhostapdconf">/etc/hostapd/hostapd.conf</a></li>
</ul>
</li>
<li><a href="#etcnetworkinterfaces-1">/etc/network/interfaces</a></li>
</ul>
</li>
<li><a href="#dhcp-server">DHCP Server</a></li>
<li><a href="#email">Email</a></li>
</ul>
</li>
<li><a href="#install-content-filtering-engine">Install Content Filtering Engine</a></li>
</ul>
</div>
</p>


  
# Getting the Box

This software should work on any debian based system. However we only support one single hardware platform in this project.

Fully tested and functional contributions for other reasonable platforms however are welcome.

We get the box here:
https://www.aliexpress.com/store/product/QOTOM-Mini-PC-Q190G4-with-4-LAN-port-using-pfsense-as-small-router-firewall-fanless-PC/108231_1000001826190.html

Don't try to order the box, Wifi or SSD from another provider - safe time here first - not money.

**Attention:**

THIS IS AN EARLY DRAFT DOCUMENTATION  - DONT BUY HARDWARE IN THE HOPE THIS WILL WORK EXACTLY AS SHOWN


# Install Debian Server

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

### /etc/hosts
```
127.0.0.1 localhost
10.1.1.1 cleanwall.lan cleanwall

# The following lines are desirable for IPv6 capable hosts
#::1 localhost ip6-localhost ip6-loopback
#ff02::1 ip6-allnodes
#ff02::2 ip6-allrouters
```

### /etc/hostname
```
cleanwall
```
Reboot anc check:

```
reboot
hostname
hostname -f
```

### /etc/apt/sources.list
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

### Update debian

```
apt-get update
apt-get upgrade
```


### Default Shell
The default 'dash' should be the right choice here. 
Switch back, if you have choosen another one:

```
dpkg-reconfigure dash
```


### Time
This was not needed:
```
apt-get install ntp ntpdate
```


### PKI
Install authorized key
```
/root/.ssh/authorized_keys
```


## Network
(minimal install was all dhcp)


### /etc/sysctl.conf

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

### /etc/network/interfaces
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



### Configure iptables Firewall

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


### /etc/network/interfaces
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

## DHCP Server
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


## Email
```
/etc/exim4/update-exim4.conf.conf
# without ipv6 localloop ::1 listen port
rm /var/log/exim4/paniclog
```



# Install Content Filtering Engine

TODO
