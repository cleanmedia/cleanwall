# 08.07.2017 CC BY-SA 4.0 license, Renato Mercurio, Cleanmedia

Prerequisites
-------------
apt-get install iptables-persistent
- obviously we will have a disaster, if we install any other firewall
- we are not using or bothering about ipv6 for the moment
- at least not on the local LAN served by this router


Time Filter
===========
deactivate:
rm time.v4
ln -s empty.load time.v4

activate:
rm time.v4
ln -s time.v4.load time.v4


Update
------
/usr/local/cleanwall/fw/fw.rules.v4.sh
- test it!
iptables-save > /etc/iptables/rules.v4


Restore, Reset or at Reboot
---------------------------
- fastest way to load big iptables also:
iptables-restore < /etc/iptables/rules.v4


