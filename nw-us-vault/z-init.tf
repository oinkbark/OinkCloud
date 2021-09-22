terraform {
  required_providers {
    vault = {
      source = "hashicorp/vault"
      version = "2.24.0"
    }
  }
}
provider "vault" {
  address = var.address
  token = var.tf_vault_root
  # Value is stored in google secret
  # but this must be a file path
  # and local_file provider does not work
  # so you have to manually paste the data in yourself :(
  ca_cert_file = "${path.module}/data/nw-us-consul-ca.manual.crt"
}
