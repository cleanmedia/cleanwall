# Cleanwall

debian based content filtering firewall


## Getting the Box

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


## Install Debian Firewall


## Install Content Filtering Engine
