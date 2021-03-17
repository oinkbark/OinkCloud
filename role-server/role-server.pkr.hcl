variable "parent_image_id" {
}

variable "digitalocean_token" {
}


source "digitalocean" "machine-image" {
  ## Required ##
  api_token = var.digitalocean_token
  image = var.parent_image_id
  region = "sfo3"
  size = "s-1vcpu-2gb"
  
  ## Optional ##
  snapshot_name = "role-server"
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
  post-processor "manifest" {
    output = "/workspace/manifest.json"
  }
}
