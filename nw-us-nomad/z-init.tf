# nomad node status -verbose -self
# https://www.nomadproject.io/docs/runtime/interpolation

terraform {
  required_providers {
    nomad = {
      source = "hashicorp/nomad"
      version = "1.4.15"
    }
  }
}
provider "nomad" {
  address =  var.address
  secret_id = var.tf_nomad_root
  vault_token = var.tf_vault_root
}
