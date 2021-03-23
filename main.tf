# To Use Cli:
# tf init
# tf login

# File Naming:
# d = data
# i = inputs
# m = main
# o = outputs

terraform {
  required_version = ">= 0.14.7"

  backend "remote" {
    organization = "OinkBark"

    workspaces {
      name = "terraform"
    }
  }
}

module "digitalocean" {
  source = "./digitalocean"
  tf_digitalocean_token = var.tf_digitalocean_token
  tf_ssh_private_key = var.tf_ssh_private_key

  vault_unseal = module.gcloud.role-server-keys.vault-unseal
  secret_writer = module.gcloud.role-server-keys.secret-writer
}
module "gcloud" {
  source = "./gcloud"
  tf_gcloud_credentials = var.tf_gcloud_credentials

  # Hashicorp Packer
  digitalocean_token = var.digitalocean_token
  
  ssh_public_keys = var.ssh_public_keys

  # Manifest build buckets
  oinkserver_domain_link = "oinkbark.com"
  # Allow oinkserver service account access to other projects
  oinkserver_observe_account = module.vault.oinkserver-observe
}
module "cloudflare" {
  source = "./cloudflare"
  tf_cloudflare_token = var.tf_cloudflare_token

  proxy_droplet = module.digitalocean.role-server.ipv4

  tubbyland = {
    domain_name = "tubbyland"
    domain_tld = "com"
    proxy = module.digitalocean.role-server.ipv4
    assets = module.digitalocean.tubbyland-assets
  }
}

module "vault" {
  source = "./vault"

  address = "https://${module.digitalocean.role-server.ipv4}:8200"
  tf_vault_root = module.gcloud.vault-root

  roles_gcp = {
    artifact_reader = module.gcloud.vault-roles.artifact-reader
    artifact_tagger = module.gcloud.vault-roles.artifact-tagger
  }
  secrets_gcp = module.gcloud.backend-keys.vault-generator
  auth_gcp =  module.gcloud.backend-keys.vault-verifier
  auth_ca_crt = module.gcloud.consul-ca-crt

  terraform = {
    digitalocean_token = var.tf_digitalocean_token
    gcloud_credentials = var.tf_gcloud_credentials
    cloudflare_token = var.tf_cloudflare_token
    ssh_private_key = var.tf_ssh_private_key
  }
  packer = {
    digitalocean_token = var.digitalocean_token
    ssh_public_keys = var.ssh_public_keys
  }
  nomad = {
    dns_certbot_token = var.dns_certbot_token
    tubbyland_oauth_emails = var.tubbyland_oauth_emails_whitelist
    tubbyland_oauth_gcp = var.tubbyland_oauth_gcp_credentials
    tubbyland_oauth_internal = module.random.tubbyland-internal
    tubbyland_db_username = var.tubbyland_db_username
    tubbyland_db_password = module.random.tubbyland-db
  }
}
module "nomad" {
  source = "./nomad"

  address = "http://${module.digitalocean.role-server.ipv4}:4646"
  tf_nomad_root = module.gcloud.nomad-root
  tf_vault_root = module.gcloud.vault-root

  #vault_oinkserver_registry = module.vault.oinkserver-registry
  vault_tubbyland_db = module.vault.tubbyland-db
}
module "random" {
  source = "./random"
}
