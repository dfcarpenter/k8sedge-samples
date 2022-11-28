### Cert Generation for OPC PLC Server

```sh
# Key Generation
openssl genrsa -des3 -out opcCA.key 2048

# Pem Certificate Generation
openssl req -x509 -new -nodes -key opcCA.key -sha256 -days 1825 -out opcCA.pem 

# CRL Generation using CA 
openssl ca -gencrl -keyfile opcCA.key -cert opcCA.pem -out opcCA.crl.pem -config crl_openssl.cnf 

# CRL Conversion to ASN.1 format 
openssl crl -inform PEM -in opcCA.crl.PEM -outform DER -out opcCA.crl
```