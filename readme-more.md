# Firewall Manipulation (optional)

```
# example (re-)install bindrpz only from the cleanwall config:
ansible-playbook install-cleanwall.yml --extra-vars "target=$INT tags=dns"

# or even simpler in this case like so:
ansible-playbook bindrpz.yml --extra-vars "target=$INT"

# reset the firewall manually w/o reboot:
ansible-playbook fw-reset.yml --extra-vars "target=$INT"
```

# Build Redwood Phrase Filter Engine

The firewall is already enforcing DNS with a powerfull RPZ blacklist. Also Safe Search is enforced using the same technology. However this list can not easily be kept up to date. And also it is not needed to do so. So we add another level of defense, a phrase filter. Because of the widespread use of SSL technologies - and the rise of mobile devices and fearless app developers, it is not advisable to bump SSL traffic in any way. So as we are already in control of the DNS, we simply spy on those DNS requests and see what comes out, when we surf on those sites. For this we will need a powerfull content analysing engine - the Redwood Filter - a fine piece of software from Andy Balholm. The spy is not included yet. We are just ready to build the engine:

```
# build and install the redwood binary:
ansible-playbook install-redwood.yml --extra-vars "target=$INT"
```


# Using Ansible Secrets (optional)
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


# Observing Temperature
We installed the lm-sensors package.
In a warm country or environment - or under heavy load conditions, it can be advisable to observe the temperature of the CPU cores. Or just if you think the device is hot and want to know for sure:
```
administrator@cleanwall:~$ sudo sensors
coretemp-isa-0000
Adapter: ISA adapter
Core 0:       +33.0°C  (high = +105.0°C, crit = +105.0°C)
Core 1:       +33.0°C  (high = +105.0°C, crit = +105.0°C)
Core 2:       +33.0°C  (high = +105.0°C, crit = +105.0°C)
Core 3:       +33.0°C  (high = +105.0°C, crit = +105.0°C)
```
Ok. This CPU is just not doing anything. So why did you buy such an expensive router? This is where we start. Now we can install a policy enforcement spy running in the background.


