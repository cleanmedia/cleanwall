# Cleanwall

debian based content filtering firewall


<p></p><div class="toc"><div class="toc">
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
<li><a href="#install-content-filtering-engine">Install Content Filtering Engine</a><ul>
<li><a href="#bind9">bind9</a><ul>
<li><ul>
<li><a href="#force-google-and-youtube-safesearch">Force Google and youtube Safesearch</a></li>
<li><a href="#force-local-nameserver">Force local nameserver</a></li>
</ul>
</li>
<li><a href="#rpz">RPZ</a></li>
</ul>
</li>
<li><a href="#apache">Apache</a></li>
<li><a href="#redwood-filter">Redwood Filter</a><ul>
<li><a href="#install-tools">Install Tools</a></li>
<li><a href="#install-golang">Install golang</a></li>
<li><a href="#test-golang">Test golang</a></li>
<li><a href="#install-redwood">Install redwood</a></li>
<li><a href="#configure-redwood">Configure Redwood</a></li>
<li><a href="#selfsigned-cert">Selfsigned Cert</a></li>
<li><a href="#redwood-init-script">Redwood Init Script</a></li>
<li><a href="#issues-deprecated">Issues (deprecated)</a></li>
<li><a href="#testing-redwood">Testing Redwood</a></li>
</ul>
</li>
<li><a href="#observing-temperature">Observing Temperature</a></li>
</ul>
</li>
</ul>
</div>
</div>

<p></p><p></p>


  
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

Boot the target system from the installation stick:

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
   * Choose cleanwall as the hostname
   * In the software selection dialog choose 'SSH server' and 'standard system utilities' only.



First boot:

* Login as user administrator and the password you gave before.

* Get ready for ansible deployments:

```
su -
apt-get install sudo
adduser administrator sudo
apt-get install ssh openssh-server
apt-get install vim sudo
adduser administrator sudo
# call visudo and add NOPASSWD to group sudo
```

<<<<<<< HEAD
* Eventually enable Time (not needed):
=======
* eventually you may have to reconfigure locales and the keyboard:
```
dpkg-reconfigure locales
dpkg-reconfigure tzdata
```

* Enable Time:
>>>>>>> b2509e186874687fe193980b8bc05ed97d8741a3

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
Reboot and check:

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
Install authorized key:
```
cat id_rsa.pub | ssh administrator@$TARGET "umask 077; mkdir -p .ssh; cat >.ssh/authorized_keys"
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
/etc/exim4/update-exim4.conf
# without ipv6 localloop ::1 listen port
rm /var/log/exim4/paniclog
```



# Install Content Filtering Engine

(EARLY DRAFT)

## bind9

Install and use bind9 as DNS
- possibly reboot shutdown -r now
- apt-get update
- apt-get install bind9
- configure it:
- http://askubuntu.com/questions/330148/how-do-i-do-a-complete-bind9-dns-server-configuration-with-a-hostname

```
/etc/bind/named.conf.options
/etc/bind/named.conf.local
/etc/resolv.conf
/etc/default/bind9 (ipv4 only for speed: OPTIONS="-4 -u bind")
/etc/bind/zones.rfc1918
```

- Activate internal DNS service
- in dhcp-server use local (10.1.1.1) DNS from bind and google as a failover
- touch /var/log/query.log ; chown bind /var/log/query.log

Force DNS (see //usr/local/cleanwall/fw/fw.rules.v4.sh)
- Add iptables force rule for DNS for any port 53 traffic (TCP and UDP)
that tries to exit via the WAN - except to 8.8.8.8
- Control the DNS (force Dyn, allow local dns hosts resolutions):

[- and force 8.8.8.8 to have the local router as the source]
(this is not needed, as local router process does not pass the dNAT restriction)

- test, if the DNS can not be changed to opendns or direct client to google


#### Force Google and youtube Safesearch
```
root@cleanwall:/etc/bind/zones# tail -5 db.rpz.vip
www.google.com CNAME forcesafesearch.google.com.
www.google.at CNAME forcesafesearch.google.com.
www.google.ch CNAME forcesafesearch.google.com.
www.google.de CNAME forcesafesearch.google.com.
www.youtube.com CNAME forcesafesearch.google.com.
etc
```

#### Force local nameserver
/etc/dhcp/dhclient.conf
```
supersede domain-name-servers 10.1.1.1, 8.8.8.8;
```


### RPZ
```
/etc/bind/named.conf.options
/etc/bind/named.conf.local
/etc/bind/zones/db.rpz
```

```

named-checkzone rpz db.rpz
named-checkzone lan db.lan
systemctl restart bind9
dig +short www.acidcow.com @10.1.1.1
```

to create db.rpz see:
/usr/local/cleanwall/lists/readme.txt


## Apache
```
apt-get install apache2
[/etc/init.d/apache2 start]
added logical interface 192.168.10.11
configure ports.conf and 000-default for this IF
allow HTTP(S) from LAN/WAN to FW in firewall
/var/www/html/index.html
enable mod_rewrite and rewrite all to index.html
a2enmod rewrite
```

add port 443 traffic (using ssl-cert):
```

[apt-get install ssl-cert]
a2enmod ssl
[a2dissite default-ssl] not needed here
mkdir /var/www/www.lan
cp /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-available/www.lan-ssl.conf
vim /etc/apache2/sites-available/www.lan-ssl.conf
adapt virtualhost ip and more if needed
a2ensite www.lan-ssl.conf
systemctl reload apache2
```

sorrypage:
- a2enmod include
- a2enmod cgid
- apache variable HTTP_HOST auswerten
- <!--#include virtual="/cgi-bin/get_categ.cgi" -->
- /var/www/dnsblock/cgi-bin/get_categ.cgi
- FROM=$(TZ=CET date -d "$START UTC" +"%H:%M") in time sorry cgi script


## Redwood Filter

### Install Tools
```
apt-get update
apt-get install strace # systemctl trace
apt-get install curl
apt-get install tcpdump # firewall debug
apt-get install git-core
git config --list
git config --global user.name "User Name"
git config --global user.email name.user@dev
```


### Install golang
```
mkdir ~/go

curl -O https://storage.googleapis.com/golang/go1.7.4.linux-amd64.tar.gz
tar xvf go1.7.4.linux-amd64.tar.gz
chown -R root:root ./go
```

vim /etc/profile.d/goenv.sh
```
export GOROOT=$HOME/go
export GOPATH=$HOME/work
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
```

source /etc/profile.d/goenv.sh


### Test golang
```
go version

mkdir $HOME/work
mkdir -p $HOME/work/src/my_project/hello
```

```
vim ~/work/src/my_project/hello/hello.go
```

```
package main

import "fmt"

func main() {
fmt.Printf("Hello, World!\n")
}
```

```
go install my_project/hello
```


### Install redwood
```
cd /root/go/src
go get github.com/andybalholm/redwood
#go get github.com/andybalholm/redwood-config
go get github.com/renatomercurio/redwood-config
cd github.com/andybalholm/redwood
vim testmode.go:
add req.Header.Set("User-Agent", "Mozilla") to req
go build
cp redwood /usr/local/cleanwall/redwood/bin/
```


### Configure Redwood

(cat /root/go/src/github.com/renatomercurio/redwood-config/README)

```
cp -r /root/go/src/github.com/renatomercurio/redwood-config /etc/redwood
cp /root/go/bin/redwood /usr/local/bin
```

Final more flexible setup:
```
cd /usr/local/cleanwall/redwood
mkdir config-bot
rsync -av /etc/redwood/ config-bot/
cd /etc/
rm -rf redwood/
ln -s /usr/local/cleanwall/redwood/config-bot redwood
```


### Selfsigned Cert
(This has been improved - see /usr/local/cleanwall/apache/certs/readme.txt)

```
CPATH=/etc/ssl/localcerts
mkdir -p $CPATH
openssl req -new -x509 -days 3650 -nodes -out ${CPATH}/cleanwall.lan.pem -keyout ${CPATH}/cleanwall.lan.key -subj '/CN=cleanwall.lan'
chmod 600 /etc/ssl/localcerts/cleanwall.lan*
cd /etc/redwood
ln -s /etc/ssl/localcerts/cleanwall.lan.key root_key.pem
ln -s /etc/ssl/localcerts/cleanwall.lan.pem root.pem
```


### Redwood Init Script
```
mkdir /var/log/redwood
vim /lib/systemd/system/redwood.service
cd /etc/systemd/system/multi-user.target.wants/
ln -s /lib/systemd/system/redwood.service redwood.service
systemctl daemon-reload
systemctl enable redwood.service
systemctl start redwood.service
```

error log:
```
journalctl -u redwood
```


### Issues (deprecated)
```
1. /usr/local/cleanwall/redwood/etc/categories/pornography/regex.list -> comment lines 3 and 5
2. add style to redwood block page
3. images.yahoo.com.de or similar (https://de.images.search.yahoo.com) was blocked => try to turn on safe search instead!
(this was the default browser choosen by dolphin mobile)
and on the PC the CN was cleanwall - and not as expected cleanwall.lan!
4. Link to internal page with known restrictions
5. Unblock page request link and unblock client request link (automatic with email)

**Main Problem of Bumping SSL**
(deprecated content)

problem with transparent ssl-bump proxy - and internally generated CONNECT req

Führt immer wieder zu fehlenden Seiten und gestörter Kommunikation
Weil die App annimmt, sie sei direkt verbunden und einige Server verlangen manchmal client auth.
Das kann der Proxy nicht wissen, welche dies sind und wann.

ergo muss ein expliziter Proxy erzwungen werden!

Fehlende Seiten und Bilder in Flipboard nur bei web-redir (with bump:
2017-02-16 19:53:02,10.1.1.102,ad.flipboard.com,52.4.224.165:443,error in handshake with client: remote error: tls: unknown certificate,
2017-02-16 19:53:02,10.1.1.102,ue.flipboard.com,52.44.209.178:443,error in handshake with client: remote error: tls: unknown certificate,
(so the mobile client presents a client cert? expecting an aws peer only)
2017-02-16 20:26:53,10.1.1.102,images.futurezone.at,83.137.116.72:443,error in handshake with client: remote error: tls: unknown certificate
und genau dieses Bild fehlt bei bump


**Other Known Issues**

* Chrome "Failed to connect to the Connection Server" nach click auf Horizon HTML access
trotz importierter authority im system store - ebenfalls mit aktiviertem webfilter
=> Problem ist Chrome!! (auch ohne webfilter interception geht es nicht)
* Skype for Business kann kein Sign-In mit aktivierter webfilter rule (trotz ff store)
=> später gings dann aber doch nach cancel und nochmals sign in button
* FF for Android is not using the OS root cert trust store (but its own db)
=> and dont even offer to import it there anymore => crippled as for Android

...
* SSL Proxy "Drony" for Android (only Android for Business has that). Aber trotzdem Spiel ohne Grenzen
https://blog.habets.se/2014/09/Secure-browser-to-proxy-communication---again.html


* Android mdns to 224.0.0.251
* acl: before send origin req
after rspfrom origin server
after scanning response
==> url allow before ssl-bump (analog squid https filter exclusions for)
- twitter
- soundhound
- .apple.com
- .icloud.com
- .mzstatic.com
```


**Conclusion:**

* Do not bump TLS - use a database instead, DNS RPZ - and, last but not least, a spying categorization engine in the background.


**Resolved Issues**
```
* unknown certificate authority because HSTS dont allow bump (facebook, wikipedia, duckduckgo)
=> import the cleanwall.lan cert into the OS trusted root CAs list (user provided space)
* direct requests to classification service give 401 (missing required API authentication)
i.e. curl http://10.1.1.1:6502/classify?url=https://golang.org
=> changed api-acls.conf
* Enable selective web redirects and test it.
* Enable WLAN and switch to it! (TPL_2.4_E83C8E)
* had this on ubuntu client resolv.conf:
nameserver 127.0.1.1
had to manually turn off:
#dns=dnsmasq
in
/etc/NetworkManager/NetworkManager.conf

* redwood would not resolv via local dns
=> force nameserver in /etc/dhcp/dhclient.conf
- redirect via DNAT was also impossible
- would require the outgoing interface to route back to another interface, which makes no sense for DNAT

* http://www.perfectgirls.net/category/[sorry.html] DNS sorry ohne CSS
=> Redirect to index
```



### Testing Redwood
```
redwood -test www.sbb.ch/home.html
chromium-browser --proxy-server="https=10.1.1.1:6510;http=10.1.1.1:6502"
curl --proxy http://10.1.1.1:6502 -v http://www.sbb.ch/home.html
curl --proxy http://10.1.1.1:6502 -vv http://www.cleanmedia.ch/agb.html
tcpdump -n -i br0 host 10.1.1.102
```


## Observing Temperature
```
apt-get install lm-sensors
sensors-detect

vim /etc/modules
# Chip drivers
coretemp

$ sensors
```

