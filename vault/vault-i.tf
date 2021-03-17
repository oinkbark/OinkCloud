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
variable "auth_gcp" {
  type = string
}
variable "secrets_gcp" {
  type = string
}
variable "auth_ca_crt" {
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
    tubbyland_oauth_gcp = string
    tubbyland_db_username = string
    tubbyland_db_password = string
  })
}
