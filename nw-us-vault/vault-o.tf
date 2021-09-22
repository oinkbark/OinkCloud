// output "oinkserver-registry" {
//   value = "/root/OinkServer/runtime/registry-reader.json"
//   #value = jsonencode(base64decode(data.vault_generic_secret.oinkserver-registry.data.private_key_data))
// }
output "tubbyland-db" {
  value = vault_generic_secret.tubbyland-db.data
}
output "tubbyland-domain-owner" {
  value = vault_gcp_secret_roleset.bucket-manager.service_account_email
}
output "oinkserver-observe" {
  value = vault_gcp_secret_roleset.observe-writer.service_account_email
}
output "rtc-db" {
  value = vault_generic_secret.rtc-db.data
}
output "ops-db" {
  value = vault_generic_secret.ops-db.data
}

output "nw-us" {
  sensitive = true
  value = {
    ca-crt = ""
    ca-bundle = templatefile("nw-us-vault/certs/ca-bundle.pem.ctmpl", {
      CLOUDFLARE = data.local_file.crt-cloudflare-ca.content,
      LETSENCRYPT = data.local_file.crt-letsencrypt-ca.content,
      OINKCLOUD = var.secrets_pki_ca_crt
    })
    tls-key = {
      leader = vault_pki_secret_backend_cert.leader.private_key
      worker = { for key, val in vault_pki_secret_backend_cert.worker : key => val.private_key }
      worker-service = { for key, val in vault_pki_secret_backend_cert.worker-service : key => val.private_key }
    }
    # Signed crt
    tls-crt = {
      leader = vault_pki_secret_backend_cert.leader.certificate
      worker = { for key, val in vault_pki_secret_backend_cert.worker : key => val.certificate }
      worker-service = { for key, val in vault_pki_secret_backend_cert.worker-service : key => val.certificate }
    }
  }
}
