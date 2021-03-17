variable "parent_image_id" {
}

variable "digitalocean_token" {
}

source "digitalocean" "base-exec" {
  ## Required ##
  api_token = var.digitalocean_token
  image = var.parent_image_id
  region = "sfo3"
  size = "s-1vcpu-1gb"

  ## Optional ##
  monitoring = true
  private_networking = true
  ipv6 = true
  snapshot_name = "base-exec"
  droplet_name = "gcloud-packer"

  ## Packer Specific ##
  ssh_username = "root"
  # Remove Packer's temp ssh key from a_k file
  ssh_clear_authorized_keys = true
}

build {
  sources = [
    "source.digitalocean.base-exec"
  ]

  provisioner "file" {
    sources = [ "./OinkServer" ]
    destination = "/root"
  }
  provisioner "shell" {
    # "ansible-galaxy collection install -r /root/ansible/requirements.yml",
    inline = [
      "ansible-playbook /root/OinkServer/ansible/base-exec.playbook.yml"
    ]
  }
  post-processor "manifest" {
    output = "/workspace/manifest.json"
  }
}
