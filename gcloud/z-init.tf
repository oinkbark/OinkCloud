# https://registry.terraform.io/providers/hashicorp/google/latest/docs
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.58.0"
    }
    google-beta = {
      source = "hashicorp/google-beta"
      version = "3.58.0"
    }
  }

  backend "remote" {
    organization = "OinkBark"

    workspaces {
      name = "terraform"
    }
  }
}
provider "google" {
  project = "oinkserver"
  credentials = var.tf_gcloud_credentials
}
provider "google-beta" {
  project = "tubbyland"
  credentials = var.tf_gcloud_credentials
}
