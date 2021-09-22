# To Use Cli:
# Move binary to /usr/local/bin and rename to tf
# tf init
# tf login

# tf taint module.<module_name>.<resource_type>.<resource_name>


# File Naming:
# d = data
# i = inputs
# m = main
# o = outputs
# _ (undersocre) = input variable
# - (dash) = resource or output variable

terraform {
  required_version = ">= 1.0.7"

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

  consul_digitalocean_token = var.consul_digitalocean_token

  vault_unseal = module.gcloud.role-server-keys.vault-unseal
  secret_writer = module.gcloud.role-server-keys.secret-writer

  # ca-crt = module.nw-us-vault.ca-crt
  vault_client = {
    nw-us = {
      ca-crt = module.gcloud.nw-us-consul-ca-crt
      tls-crt = {
        leader = module.vault.nw-us.tls-crt.leader
        worker = module.vault.nw-us.tls-crt.worker
        worker-service = module.vault.nw-us.tls-crt.worker-service
      }
      tls-key = {
        leader = module.vault.nw-us.tls-key.leader
        worker = module.vault.nw-us.tls-key.worker
        worker-service = module.vault.nw-us.tls-key.worker-service
      }
    }
  }
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

  proxy_droplet = module.digitalocean.nw-us-leader.ipv4
  worker_droplet = module.digitalocean.nw-us-worker["1"].ipv4

  tubbyland = {
    domain_name = "tubbyland"
    domain_tld = "com"
    proxy = module.digitalocean.nw-us-leader.ipv4
    assets = module.digitalocean.tubbyland-assets
  }
}

# Todo: rename to nw-us-vault
module "vault" {
  source = "./nw-us-vault"

  address = "https://${module.digitalocean.nw-us-server.ipv4}:8200"
  tf_vault_root = module.gcloud.nw-us-vault-root

  roles_gcp = {
    artifact_reader = module.gcloud.vault-roles.artifact-reader
    artifact_tagger = module.gcloud.vault-roles.artifact-tagger
  }
  
  secrets_gcp = module.gcloud.backend-keys.vault-generator
  secrets_pki_ca_crt = module.gcloud.nw-us-consul-ca-crt
  secrets_pki_ca_key = module.gcloud.nw-us-consul-ca-key
  secrets_pki_tls_csr = {
    leader = {
      public_ip = module.digitalocean.nw-us-leader.ipv4
      private_ip = module.digitalocean.nw-us-leader.ipv4-private
    }
    worker = module.digitalocean.nw-us-worker
  }

  auth_gcp =  module.gcloud.backend-keys.vault-verifier
  # The certificates are issued by vault which has the CA key embedded into it
  # So when new certs are issued it should be fine
  auth_ca_crt = module.gcloud.nw-us-consul-ca-crt

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

    rtc_db_password = var.rtc_db_password
    ops_db_password = var.ops_db_password
  }
}
# Todo: rename to nw-us-nomad
module "nomad" {
  source = "./nw-us-nomad"

  address = "http://${module.digitalocean.nw-us-server.ipv4}:4646"
  tf_nomad_root = module.gcloud.nw-us-nomad-root
  tf_vault_root = module.gcloud.nw-us-vault-root

  #vault_oinkserver_registry = module.vault.oinkserver-registry
  vault_tubbyland_db = module.vault.tubbyland-db
  vault_rtc_db = module.vault.rtc-db
  vault_ops_db = module.vault.ops-db
  vault_ca_bundle = module.vault.nw-us.ca-bundle
}
// module "tls" {
//   source = "./tls"

//   nw-us = {
//     leader = {
//       public_ip = module.digitalocean.nw-us-leader.ipv4
//       private_ip = module.digitalocean.nw-us-leader.ipv4-private
//       private_key = module.vault.nw-us.tls-key.leader
//     }
//   }
// }
module "random" {
  source = "./random"
}
