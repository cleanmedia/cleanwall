Self Signed Certificate
=======================
following https://ram.k0a1a.net/self-signed_https_cert_after_chrome_58

Create CA key and cert

# openssl genrsa -out cleanwall_rootCA.key 2048
# openssl req -x509 -new -nodes -key cleanwall_rootCA.key -sha256 -days 3650 -out cleanwall_rootCA.pem
Create cleanwall_rootCA.csr.cnf

# cleanwall_rootCA.csr.cnf
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn

[dn]
C=CH
ST=Bern
L=Zollikofen
OU=local_RootCA
emailAddress=root@cleanwall.lan
CN = cleanwall.lan

Create v3.ext configuration file

# v3.ext
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = cleanwall.lan
DNS.2 = wall.lan
DNS.3 = dav.lan
DNS.4 = police.lan
DNS.5 = web2py.lan 

Create server key

# openssl req -new -sha256 -nodes -out cleanwall.csr -newkey rsa:2048 -keyout cleanwall.key -config <( cat cleanwall_rootCA.csr.cnf )

Create server cert

# openssl x509 -req -in cleanwall.csr -CA cleanwall_rootCA.pem -CAkey cleanwall_rootCA.key -CAcreateserial -out cleanwall.crt -days 3650 -sha256 -extfile v3.ext

Add cert and key to Apache2 site-file, HTTPS (port 443) section

SSLCertificateFile       /usr/local/cleanwall/apache/certs/cleanwall.crt
SSLCertificateKeyFile    /usr/local/cleanwall/apache/certs/cleanwall.key

Copy cleanwall_rootCA.pem from the server to your machine..

# scp you@cleanwall.lan:~/cleanwall_rootCA.pem .

Add cert to the browser

Chromium -> Setting -> (Advanced) Manage Certificates -> Import -> 'cleanwall_rootCA.pem'


For Apache2 add the following to site-file, HTTP (port 80) section

Header unset Strict-Transport-Security
Header always set Strict-Transport-Security "max-age=0;includeSubDomains"

a2enmod headers

Restart apache2
---------------
systemctl restart apache2.service

