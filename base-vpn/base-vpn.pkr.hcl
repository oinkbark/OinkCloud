variable "parent_image_id" {
  default = "debian-10-x64"
}

variable "digitalocean_token" {
}

source "digitalocean" "base-deb10" {
  ## Required ##
  api_token = var.digitalocean_token
  image = var.parent_image_id
  region = "sfo3"
  size = "s-1vcpu-1gb"


  ## Optional ##
  droplet_name = "gcloud-packer"
  snapshot_name = "base-vpn"

  ## Packer Specific ##
  ssh_username = "root"
  # Remove Packer's temp ssh key from main authorized_keys file
  ssh_clear_authorized_keys = true
}

build {
  sources = [
    "source.digitalocean.base-vpn"
  ]
  provisioner "file" {
    source = "/workspace/ssh_public_keys.txt"
    destination = ".ssh/oink.authorized_keys"
  }
  provisioner "file" {
    sources = [ "./linux-config/systemctl/" ]
    destination = "/usr/lib/systemd/system/"
  }
  provisioner "file" {
    sources = [ "./linux-config/etc/direct/" ]
    destination = "/etc/"
  }
  provisioner "file" {
    source = "./linux-config/etc/resolv.conf"
    destination = "/etc/resolvconf/resolv.conf.d/head"
  }
  provisioner "shell" {
    inline = [
      "export DEBIAN_FRONTEND=noninteractive",
      "sudo apt update -y -qq",
      "sudo apt install -y -qq gnupg2"
    ]
  }
  provisioner "file" {
    source = "./linux-config/etc/custom-sources.list"
    destination = "/etc/apt/sources.list.d/custom-sources.list"
  }
  # Ansible and Digitalocean APT Keys
  provisioner "shell" {
    inline = [
      "export DEBIAN_FRONTEND=noninteractive",
      "sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367 DE88104AA4C6383F",
      "sudo apt update -y -qq",
      "sudo apt install -y -qq ansible",
      "sudo ansible --version"
    ]
  }
  post-processor "manifest" {
    output = "/workspace/manifest.json"
  }
}
