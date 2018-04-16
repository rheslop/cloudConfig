### DEFINE VARIABLES ####

TEMPLATES_DIR=
OPENSSL_WORKING_DIR=${TEMPLATES_DIR}/certs
TARGET_IPADDR=
TARGET_FQDN=
COUNTRY_NAME=
STATE=
LOCALITY=
ORGANIZATION=

function AUTO_OPENSSL {

WRITE_OPENSSL
GENERATE_CERTIFICATES
WRITE_TEMPLATES

}

function WRITE_OPENSSL {
echo "" # stdout buffer start
cat > $OPENSSL_WORKING_DIR/openssl.cnf << EOF
HOME                    = .
RANDFILE                = \$ENV::HOME/.rnd
oid_section             = new_oids

[ new_oids ]

tsa_policy1 = 1.2.3.4.1
tsa_policy2 = 1.2.3.4.5.6
tsa_policy3 = 1.2.3.4.5.7

[ ca ]
default_ca      = CA_default

[ CA_default ]

dir             = /etc/pki/CA           # Where everything is kept
certs           = \$dir/certs            # Where the issued certs are kept
crl_dir         = \$dir/crl              # Where the issued crl are kept
database        = \$dir/index.txt        # database index file.
                                        # several ctificates with same subject.
new_certs_dir   = \$dir/newcerts         # default place for new certs.

certificate     = \$dir/cacert.pem       # The CA certificate
serial          = \$dir/serial           # The current serial number
crlnumber       = \$dir/crlnumber        # the current crl number
                                        # must be commented out to leave a V1 CRL
crl             = \$dir/crl.pem          # The current CRL
private_key     = ./ca.key.pem
RANDFILE        = \$dir/private/.rand    # private random number file

x509_extensions = usr_cert              # The extentions to add to the cert

name_opt        = ca_default            # Subject Name options
cert_opt        = ca_default            # Certificate field options

copy_extensions = copy

default_days    = 365                   # how long to certify for
default_crl_days= 30                    # how long before next CRL
default_md      = sha256                # use SHA-256 by default
preserve        = no                    # keep passed DN ordering

policy          = policy_match

[ policy_match ]
countryName             = match
stateOrProvinceName     = match
organizationName        = match
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ policy_anything ]
countryName             = optional
stateOrProvinceName     = optional
localityName            = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ req ]
default_bits            = 2048
default_md              = sha256
default_keyfile         = privkey.pem
distinguished_name      = req_distinguished_name
attributes              = req_attributes
x509_extensions = v3_ca # The extentions to add to the self signed cert

string_mask = utf8only

req_extensions = v3_req # The extensions to add to a certificate request

[ req_distinguished_name ]
countryName                     = Country Name (2 letter code)
countryName_default             = $COUNTRY
countryName_min                 = 2
countryName_max                 = 2

stateOrProvinceName             = State or Province Name (full name)
stateOrProvinceName_default     = $STATE

localityName                    = Locality Name (eg, city)
localityName_default            = $LOCALITY

0.organizationName              = Organization Name (eg, company)
0.organizationName_default      = $ORGANIZATION

organizationalUnitName          = Organizational Unit Name (eg, section)

commonName                      = Common Name (eg, your name or your server\'s hostname)
commonName_max                  = 64
commonName_default              = $TARGET_IPADDR

emailAddress                    = Email Address
emailAddress_max                = 64

[ req_attributes ]
challengePassword               = A challenge password
challengePassword_min           = 4
challengePassword_max           = 20

unstructuredName                = An optional company name

[ usr_cert ]

basicConstraints=CA:FALSE

nsComment                       = "OpenSSL Generated Certificate"

subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer

[ v3_req ]

basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[ v3_ca ]

subjectAltName = @alt_names
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer

basicConstraints = CA:true

[ crl_ext ]

authorityKeyIdentifier=keyid:always

[ proxy_cert_ext ]


basicConstraints=CA:FALSE

nsComment                       = "OpenSSL Generated Certificate"

subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer

proxyCertInfo=critical,language:id-ppl-anyLanguage,pathlen:3,policy:foo

[ tsa ]

default_tsa = tsa_config1       # the default TSA section

[ tsa_config1 ]

dir             = ./demoCA              # TSA root directory
serial          = \$dir/tsaserial        # The current serial number (mandatory)
crypto_device   = builtin               # OpenSSL engine to use for signing
signer_cert     = \$dir/tsacert.pem      # The TSA signing certificate
                                        # (optional)
certs           = \$dir/cacert.pem       # Certificate chain to include in reply
                                        # (optional)
signer_key      = \$dir/private/tsakey.pem # The TSA private key (optional)

default_policy  = tsa_policy1           # Policy if request did not specify it
                                        # (optional)
other_policies  = tsa_policy2, tsa_policy3      # acceptable policies (optional)
digests         = sha1, sha256, sha384, sha512  # Acceptable message digests (mandatory)
accuracy        = secs:1, millisecs:500, microsecs:100  # (optional)
clock_precision_digits  = 0     # number of digits after dot. (optional)
ordering                = yes   # Is ordering defined for timestamps?
                                # (optional, default: no)
tsa_name                = yes   # Must the TSA name be included in the reply?
                                # (optional, default: no)
ess_cert_id_chain       = no    # Must the ESS cert id chain be included?
                                # (optional, default: no)

[alt_names]
IP.1 = $TARGET_IPADDR
DNS.1 = $TARGET_FQDN

EOF

if [ $? == 0 ]; then
    echo "${OPENSSL_WORKING_DIR}/openssl.cnf written."
else
    echo "Failed writing ${OPENSSL_WORKING_DIR}/openssl.cnf - halting."
fi

echo "" # stdout buffer end
}

function GENERATE_CERTIFICATES {

    echo "" # stdout buffer start
    rpm -q openssl > /dev/null || sudo yum -y install openssl
    rpm -q openssl > /dev/null || exit 1

    if [ ! -d $OPENSSL_WORKING_DIR ]; then
        mkdir -p $OPENSSL_WORKING_DIR
    fi

#######################
# Create Certificates #
#######################

    if [ ! -f /etc/pki/CA/index.txt ]; then
        sudo touch /etc/pki/CA/index.txt
        echo -n "Creating /etc/pki/CA/serial - "
        sudo echo '1000' | sudo tee /etc/pki/CA/serial
    fi

    if [ ! -f $OPENSSL_WORKING_DIR/ca.key.pem ]; then
        echo "Generating Certificat Authority private key."
        openssl genrsa -out $OPENSSL_WORKING_DIR/ca.key.pem
    else
        echo "Certificate Authority private key present...skipping."
    fi

    if [ ! -f $OPENSSL_WORKING_DIR/ca.crt.pem ]; then
        echo "Generating root CA."
        openssl req -key $OPENSSL_WORKING_DIR/ca.key.pem -new -x509 -days 3650 -extensions v3_ca -out $OPENSSL_WORKING_DIR/ca.crt.pem -subj "/C=$COUNTRY_NAME/ST=$STATE/L=$LOCALITY/O=$ORGANIZATION/CN=$TARGET_FQDN"
    else
        echo "Root CA present...skipping."
    fi

    echo "Updating /etc/pki/ca-trust/anchors/"
    sudo cp $OPENSSL_WORKING_DIR/ca.crt.pem /etc/pki/ca-trust/source/anchors/
    sudo update-ca-trust extract

    if [ ! -f $OPENSSL_WORKING_DIR/server.key.pem ]; then
        echo "Creating server private key."
        openssl genrsa -out $OPENSSL_WORKING_DIR/server.key.pem 2048
    else
        echo "Server private key present...skipping."
    fi

    if [ ! -f $OPENSSL_WORKING_DIR/server.csr.pem ]; then
        echo "Generating certificate signing request."
        openssl req -config $OPENSSL_WORKING_DIR/openssl.cnf -key $OPENSSL_WORKING_DIR/server.key.pem -new -out $OPENSSL_WORKING_DIR/server.csr.pem -subj "/C=$COUNTRY_NAME/ST=$STATE/L=$LOCALITY/O=$ORGANIZATION/CN=$TARGET_FQDN"
    else
        echo "Certificate signing request present...skipping."
    fi

    if [ ! -f $OPENSSL_WORKING_DIR/server.crt.pem ]; then
        echo "Creating signed certificate."
        sudo openssl ca -batch -config $OPENSSL_WORKING_DIR/openssl.cnf -extensions v3_req -days 3650 -in $OPENSSL_WORKING_DIR/server.csr.pem -out $OPENSSL_WORKING_DIR/server.crt.pem -cert $OPENSSL_WORKING_DIR/ca.crt.pem -keyfile $OPENSSL_WORKING_DIR/ca.key.pem
    else
        echo "Server certificate present...skipping."
    fi
    echo "" # stdout buffer end

}

function WRITE_TEMPLATES {

echo "" # stdout buffer start
echo "Writing ${TEMPLATES_DIR}/environments/enable-tls.yaml."

if [ ! -d ${TEMPLATES_DIR}/environments ]; then
    echo "${TEMPLATES_DIR}/environments not present...creating." 
    mkdir -p ${TEMPLATES_DIR}/environments
fi

cat > ${TEMPLATES_DIR}/environments/enable-tls.yaml << EOF
parameter_defaults:
  SSLCertificate: |
EOF

FILE=${OPENSSL_WORKING_DIR}/server.crt.pem

while read -r LINE; do
        if [ "${LINE}" == '-----BEGIN CERTIFICATE-----' ]; then ECHO=ON; fi
        if [ "${ECHO}" == "ON" ]; then echo "    ${LINE}" >> ${TEMPLATES_DIR}/environments/enable-tls.yaml; fi
        if [ "${LINE}" == '-----END CERTIFICATE-----' ]; then unset ECHO; fi
done < ${FILE}

cat >> ${TEMPLATES_DIR}/environments/enable-tls.yaml << EOF
  SSLIntermediateCertificate: ''
  SSLKey: |
EOF

FILE=${OPENSSL_WORKING_DIR}/server.key.pem

while read -r LINE; do
        if [ "${LINE}" == '-----BEGIN RSA PRIVATE KEY-----' ]; then ECHO=ON; fi
        if [ "${ECHO}" == "ON" ]; then echo "    ${LINE}" >> ${TEMPLATES_DIR}/environments/enable-tls.yaml; fi
        if [ "${LINE}" == '-----END RSA PRIVATE KEY-----' ]; then unset ECHO; fi
done < ${FILE}

cat >> ${TEMPLATES_DIR}/environments/enable-tls.yaml << EOF
resource_registry:
  OS::TripleO::NodeTLSData: /usr/share/openstack-tripleo-heat-templates/puppet/extraconfig/tls/tls-cert-inject.yaml
EOF

echo "Writing ${TEMPLATES_DIR}/environments/inject-trust-anchor.yaml."

cat > ${TEMPLATES_DIR}/environments/inject-trust-anchor.yaml << EOF
parameter_defaults:
  SSLRootCertificate: |
EOF

FILE=${OPENSSL_WORKING_DIR}/ca.crt.pem

while read -r LINE; do
        if [ "${LINE}" == '-----BEGIN CERTIFICATE-----' ]; then ECHO=ON; fi
        if [ "${ECHO}" == "ON" ]; then echo "    ${LINE}" >> ${TEMPLATES_DIR}/environments/inject-trust-anchor.yaml; fi
        if [ "${LINE}" == '-----END CERTIFICATE-----' ]; then unset ECHO; fi
done < ${FILE}

cat >> ${TEMPLATES_DIR}/environments/inject-trust-anchor.yaml << EOF
resource_registry:
  OS::TripleO::NodeTLSCAData: /usr/share/openstack-tripleo-heat-templates/puppet/extraconfig/tls/ca-inject.yaml
EOF

echo "" # stdout end buffer
}

AUTO_OPENSSL
