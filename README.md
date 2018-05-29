# Cleanwall

debian based content filtering firewall



<p><div class="toc">
<ul>
<li><a href="#introduction">Introduction</a></li>
<li><a href="#getting-the-box">Getting the Box</a></li>
<li><a href="#install-debian">Install Debian</a></li>
<li><a href="#get-ready-for-ansible-one-time-only">Get Ready for Ansible (one time only)</a></li>
<li><a href="#install-cleanwall-firewall">Install Cleanwall Firewall</a></li>
</ul>
</div>
</p>


# Introduction

Cleanwall is a debian based firewall. It currently includes two bind9 response policy zones to add blacklisting to it's name services and to enforce safe search on search engines. Both to remove adult content from the Internet traffic and to get rid of some obviously evil sites. If you don't need filtering it is enaugh to remove these two bind9 response policy zones and you have a generic firewall router. This can be done by just using install-firewall.yml instead of install-cleanwall.yml.

The current release as of that date of checkin is stable and working.

# Getting the Box

This software should work on any debian based system. However we only support one single hardware platform in this project.

Fully tested and functional contributions for other reasonable platforms however are welcome.

We get the box here:

https://www.aliexpress.com/store/product/QOTOM-Mini-PC-Q190G4-with-4-LAN-port-using-pfsense-as-small-router-firewall-fanless-PC/108231_1000001826190.html

You must add Wifi and 4GB RAM.


# Install Debian

To give a background of what is being done here, we basically follow this tutorial:

https://www.howtoforge.com/tutorial/debian-minimal-server/

The install image is an official stable debian network install image. The only reason to use the non-free variation is the missing Ralink rt2870.bin driver. We download this latest image:

http://cdimage.debian.org/cdimage/unofficial/non-free/cd-including-firmware/archive/9.3.0+nonfree/amd64/iso-cd/firmware-9.3.0-amd64-netinst.iso

And burn it to an USB stick (double check first, if /dev/sdc is right for you):

```
dd if=/home/user/Downloads/firmware-9.3.0-amd64-netinst.iso of=/dev/sdc bs=4M status=progress; sync
```

Boot the target system from the installation stick:

* Attach Switch or Router with Internet connection to LAN1 (will become WAN later)
* Attach USB keyboard
* Attach USB stick (burned before)
* Attach VGA monitor
* Attach power
* Push power button and then DEL or ESC to enter the Board Firmware (EFI)
   * Advanced > CSM > enable CSM and use all Legacy
   * choose boot order to enable USB first
   * may look different on newer engines (see readme-hardware.md about UEFI for details)
* Boot
* Choose "Install" to use the text based installer
* Follow more or less the mentioned tutorial with the following exceptions:
   * Before choosing the guided partitioning, manually remove (delete) all partitions.
   * Choose your keyboard, location and language, that suites your needs.
   * Choose 'cleanwall' as the hostname and 'lan' as the domain
   * In the software selection dialog choose 'SSH server' and 'standard system utilities' only.


First boot:

* Login as user administrator and the password you gave before.

* Get ready for ansible deployments:

```
su -
apt-get install vim sudo
adduser administrator sudo
visudo  # change to "%sudo  ALL=(ALL) NOPASSWD:ALL" for ansible
```

* Optionally: if you have to reconfigure locales and the keyboard:

```
dpkg-reconfigure locales
dpkg-reconfigure tzdata
```

* Optionally: if you have to enable Time after installing from behind a firewall:

```
systemctl enable systemd-timesyncd.service
systemctl start systemd-timesyncd.service
```

# Get Ready for Ansible (one time only)

This is how we prepare our developer linux computer to be able to install the cleanwall target system. It is needed only once and can be done from Ubuntu.

```
TARGET=192.168.11.114 # set to the target machine's IP
DEV=192.168.11.149 # IP of developer linux desktop used to deploy the target

ssh $DEV
# eventually re-create the login key:
ssh-keygen # if this was not safely done before
# send the public trust key to target:
cat ~/.ssh/id_rsa.pub | ssh administrator@$TARGET "umask 077; mkdir -p .ssh; cat >.ssh/authorized_keys"
# check if it works without password now:
ssh administrator@$TARGET

# checkout:
mkdir deploy
cd ~/deploy
git clone https://github.com/cleanmedia/cleanwall.git
cd cleanwall

# get really ready for ansible:
sudo apt install ansible

# get ready for git LFS:
curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
sudo apt-get install git-lfs
git lfs track "*.rpz"
git lfs track "*.li"
git lfs track "*.db"
```

# Install Cleanwall Firewall

```
# Change WLAN Password (wpa_passphrase) in hostapd.conf
vim files/usr/local/cleanwall/wlan/hostapd.conf

# Recreate cleanwall certificates:
cd files/usr/local/cleanwall/apache/certs
./recreate.sh
cd -

# install the cleanwall firewall:
ansible-playbook install-cleanwall.yml --extra-vars "target=$INT"

# (re-)initialize the firewall after parameter changes:
ansible-playbook fw-store.yml --extra-vars "target=$INT"
```

Reboot your Cleanwall and enjoy!

Remember, LAN1 is your WAN interface getting its "public" IP address from the upstream router. LAN2 to LAN4 and WLAN0 are bridged client interfaces and cleanwall serves cleaned IP addresses to them in the 10.1.1.X range.

