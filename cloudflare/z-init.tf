# https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs
terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "2.18.0"
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