Build
=====
```
INT=192.168.11.114 # target machine to be installed
DEV=192.168.11.149 # developer linux desktop used to deploy the target

# Change WLAN Password (wpa_passphrase) in hostapd.conf
vim files/etc/hostapd/hostapd.conf

# Recreate cleanwall certificates:
cd files/apache/certs
./recreate.sh
cd -

# install the cleanwall basic config:
ansible-playbook install-cleanwall.yml --extra-vars "target=$INT"

# example (re-)install dns / rpz only from the cleanwall config:
ansible-playbook install-cleanwall.yml --extra-vars "target=$INT tags=dns"

# build and install the redwood binary:
ansible-playbook install-redwood.yml --extra-vars "target=$INT"


# (re-)initialize the firewall after parameter changes:
ansible-playbook fw-store.yml --extra-vars "target=$INT"
# reset the firewall manually w/o reboot:
ansible-playbook fw-reset.yml --extra-vars "target=$INT"
```


Initialize (one time only)
==========================
```
ssh $DEV
su -
# re-create the login key (first time - needs root password):
ssh-keygen # if it is not created yet
cat ~/.ssh/id_rsa.pub | ssh administrator@$INT "umask 077; mkdir -p .ssh; cat >.ssh/authorized_keys"
ssh administrator@$INT

# checkout:
cd ~/deploy
git clone https://github.com/cleanmedia/cleanwall.git
cd cleanwall

# get ready for ansible:
sudo apt install ansible

# get ready for git LFS:
curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
sudo apt-get install git-lfs
git lfs track "*.rpz"
git lfs track "*.li"
```


Using Secrets (optional)
========================
```
cat group_vars/all/secret.yml
# vars/secret
---
my_user: maxmuster
my_pass: password

ansible-vault encrypt group_vars/all/secret.yml # encrypt file using new password
ansible-vault decrypt group_vars/all/secret.yml # decrypt using old password
ansible-vault view group_vars/all/secret.yml # view plain text vars (w/o in place decryption)
ansible-playbook [--ask-vault-pass | --vault_pass_file ~/.vpass]

# env support:
echo -n "<ansible_mydomain_vault_pass>" > .ansible_mydomain_vault_pass.txt
chmod 400 .ansible_mydomain_vault_pass.txt
echo "export ANSIBLE_VAULT_PASSWORD_FILE=~/.vpass" >> ~/.bash_profile

# to switch or start the ansible vault context "mydomain":
rm -f .vpass
ln -s .ansible_mydomain_vault_pass.txt .vpass
```

