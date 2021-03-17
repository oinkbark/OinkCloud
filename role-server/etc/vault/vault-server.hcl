ui = true

#consul kv delete -recurse vault/
# Storage must exist on a volume to surive new droplets

storage "consul" {
  address = "169.254.1.1:8500"
  path = "vault/"
}

listener "tcp" {
  address = "[::]:8200"
  tls_cert_file = "/root/OinkServer/openssl/service.consul-tls.crt"
  tls_key_file = "/root/OinkServer/openssl/service.consul-tls.key"
}

// listener "tcp" {
//   address = "169.254.1.1:8200"
//   tls_cert_file="/root/OinkServer/openssl/service.consul-tls.crt"
//   tls_key_file="/root/OinkServer/openssl/service.consul-tls.key"
// }

// listener "tcp" {
//   address = "{{ GetPublicIP }}:8200"
//   tls_cert_file="/root/OinkServer/openssl/service.consul-tls.crt"
//   tls_key_file="/root/OinkServer/openssl/service.consul-tls.key"
// }

seal "gcpckms" {
  # Cannot be stored inside vault because that is what is used to unseal it
  credentials = "SET BY ANSIBLE"
  # GOOGLE_PROJECT env var
  project     = "oinkserver"
  region      = "global"
  key_ring    = "vault-keyring"
  crypto_key  = "vault-key"
}
