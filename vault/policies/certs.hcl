path "kv-v2/consul/config/encryption" {
  capabilities = ["read"]
}
path "kv-v2/nomad/config/encryption" {
  capabilities = ["read"]
}
path "secret/oinkserver/certs/*" {
  capabilities = ["read"]
}