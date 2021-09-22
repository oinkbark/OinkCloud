variable "parent_image_id" {
}

variable "digitalocean_token" {
}


source "digitalocean" "machine-image" {
  ## Required ##
  api_token = var.digitalocean_token
  image = var.parent_image_id
  region = "sfo3"
  size = "s-1vcpu-1gb"
  
  ## Optional ##
  snapshot_name = "role-client"
  droplet_name = "gcloud-packer"

  ## Packer Specific ##
  ssh_username = "root"
  # Remove Packer's temp ssh key
  ssh_clear_authorized_keys = true
}

build {
  sources = [
    "source.digitalocean.machine-image"
  ]
  provisioner "file" {
    sources = [ "./OinkServer" ]
    destination = "/root"
  }
  provisioner "file" {
    sources = [ "./etc/consul/" ]
    destination = "/etc/consul.d/"
  }
  provisioner "file" {
    sources = [ "./etc/vault/" ]
    destination = "/etc/vault.d/"
  }
  provisioner "file" {
    sources = [ "./etc/nomad/" ]
    destination = "/etc/nomad.d/"
  }
  provisioner "file" {
    sources = [ "./etc/docker/" ]
    destination = "/etc/docker/"
  }
  post-processor "manifest" {
    output = "/workspace/manifest.json"
  }
}

packer {
  required_version = ">= 1.7.4"
  required_plugins {
    digitalocean = {
      version = ">= 1.0.1"
      source  = "github.com/hashicorp/digitalocean"
    }
  }
}
