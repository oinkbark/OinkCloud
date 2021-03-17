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
