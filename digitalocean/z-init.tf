# https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs
terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.5.1"
    }
  }
  backend "remote" {
    organization = "OinkBark"

    workspaces {
      name = "terraform"
    }
  }
}
provider "digitalocean" {
  token = var.tf_digitalocean_token
}