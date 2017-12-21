Build
=====
```
INT=192.168.0.234 # target machine to be installed
DEV=192.168.0.192 # developer linux desktop used to deploy the target

# Finish the server installation
ansible-playbook server.yml --extra-vars "target=$INT"

# build and install the redwood binary:
ansible-playbook install-redwood.yml --extra-vars "target=$INT"

# example install a cleanwall config:
ansible-playbook install-cleanwall.yml --extra-vars "target=$INT"

# example install a cleanwall config - dns with rpz only:
ansible-playbook install-cleanwall.yml --extra-vars "target=$INT tags=dns"


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
git clone https://github.com/cm/c1.git
cd c1
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

