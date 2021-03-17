terraform {
  required_providers {
    nomad = {
      source = "hashicorp/nomad"
      version = "1.4.13"
    }
  }
}
provider "nomad" {
  address =  var.address
  secret_id = var.tf_nomad_root
  vault_token = var.tf_vault_root
}
