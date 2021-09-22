# https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs
terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.11.1"
    }
  }
}
provider "digitalocean" {
  token = var.tf_digitalocean_token
}