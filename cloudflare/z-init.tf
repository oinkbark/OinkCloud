# https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs
terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "2.19.2"
    }
  }
  backend "remote" {
    organization = "OinkBark"

    workspaces {
      name = "terraform"
    }
  }
}

provider "cloudflare" {
  api_token = var.tf_cloudflare_token
}