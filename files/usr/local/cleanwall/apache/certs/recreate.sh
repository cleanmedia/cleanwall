# (Re-)Create root CA key pair

openssl genrsa -out cleanwall_rootCA.key 2048
openssl req -x509 -new -nodes -key cleanwall_rootCA.key -sha256 -days 3650 -out cleanwall_rootCA.pem -config <( cat cleanwall_rootCA.csr.cnf )

# (Re-)Create server key

openssl req -new -sha256 -nodes -out cleanwall.csr -newkey rsa:2048 -keyout cleanwall.key -config <( cat cleanwall_rootCA.csr.cnf )

# (Re-)Create server cert

openssl x509 -req -in cleanwall.csr -CA cleanwall_rootCA.pem -CAkey cleanwall_rootCA.key -CAcreateserial -out cleanwall.crt -days 3650 -sha256 -extfile v3.ext

