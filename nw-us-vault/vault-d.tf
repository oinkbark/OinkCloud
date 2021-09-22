// data "vault_generic_secret" "oinkserver-registry" {
//   path = "gcp/key/registry-reader"
// }

# Certs
data "local_file" "crt-cloudflare-ca" {
  filename = "${path.module}/certs/cloudflare-ca.pem"
}
data "local_file" "crt-letsencrypt-ca" {
  filename = "${path.module}/certs/letsencrypt-ca.pem"
}
