output "role-server-keys" {
  value = {
    secret-writer = google_secret_manager_secret_version.secret-writer.secret_data
    vault-unseal = google_secret_manager_secret_version.vault-unseal.secret_data
  }
}

output "backend-keys" {
  value = {
    vault-generator = google_secret_manager_secret_version.vault-generator.secret_data
    vault-verifier = google_secret_manager_secret_version.vault-verifier.secret_data
  }
}

// module.gcloud.role-server-keys.oauth-gcp.tubbyland
// oauth-gcp = {
//   tubbyland = google_iap_client.tubbyland.secret
// }

output "vault-root" {
  sensitive = true
  value = data.google_secret_manager_secret_version.vault-root.secret_data
}
output "nomad-root" {
  sensitive = true
  value = data.google_secret_manager_secret_version.nomad-root.secret_data
}
output "consul-ca-crt" {
  sensitive = true
  value = data.google_secret_manager_secret_version.consul-ca-crt.secret_data
}
