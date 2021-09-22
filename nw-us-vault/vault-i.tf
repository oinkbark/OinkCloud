# Provider
variable "tf_vault_root" {
  type = string
  sensitive = true
}
variable "address" {
  type = string
}
// variable "ca_crt" {
//   type = string
// }

# Resources
## Secret backends
// variable "backends" {
//   type = object({
//     secrets = {
//       gcp = string
//       pki_crt = string
//       pki_key = string
//     }
//     auth = {
//       ca_crt = string
//       gcp = string
//     }
//     roles = {
//       gcp = object({
//         artifact_reader = string
//         artifact_tagger = string
//       })
//     }
//   })
// }
variable "secrets_gcp" {
  type = string
}
variable "secrets_pki_ca_crt" {
  type = string
}
variable "secrets_pki_ca_key" {
  type = string
}
variable "secrets_pki_tls_csr" {
  type = object({
    leader = object({
      public_ip = string
      private_ip = string
    })
    #[string] = object({
    #  public_ip = string
    #  private_ip = string
    #})
    worker = map(any)
  })
}
variable "roles_gcp" {
  type = object({
    artifact_reader = string
    artifact_tagger = string
  })
}
# Auth backends
variable "auth_ca_crt" {
  type = string
}
variable "auth_gcp" {
  type = string
}

# Secrets
variable "terraform" {
  type = object({
    digitalocean_token = string
    gcloud_credentials = string
    cloudflare_token = string
    ssh_private_key = string
  })
}
variable "packer" {
  type = object({
    digitalocean_token = string
    ssh_public_keys = string
  })
}
variable "nomad" {
  type = object({
    dns_certbot_token = string

    tubbyland_oauth_emails = list(string)
    tubbyland_oauth_internal = list(string)
    tubbyland_oauth_gcp = string
    tubbyland_db_username = string
    tubbyland_db_password = string

    rtc_db_password = string
    ops_db_password = string
  })
}
