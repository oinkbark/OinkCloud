resource "digitalocean_project" "oinkcloud" {
  name        = "OinkCloud"
  description = "OinkCloud Central Operations"
  purpose     = "Web Application"
  environment = "Production"
  resources = [
    digitalocean_droplet.role-server.urn,
    digitalocean_volume.role-server.urn,
    digitalocean_volume.tubbyland.urn
  ]
}
resource "digitalocean_vpc" "oinkcloud-sfo3" {
  name = "oinkcloud-sfo3"
  region = var.cluster.region
}

# Volumes
resource "digitalocean_volume" "role-server" {
  region = var.cluster.region
  name = "role-server"
  size = 3
  initial_filesystem_type = "xfs"
}
resource "digitalocean_volume" "tubbyland" {
  region = var.cluster.region
  name = "tubbyland"
  size = 3
  initial_filesystem_type = "xfs"
}

# Droplets
resource "digitalocean_droplet" "role-server" {
  name   = "snapshot-server"
  size   = "s-2vcpu-4gb"
  region = var.cluster.region

  image  = data.digitalocean_droplet_snapshot.role-server.id
  volume_ids = [ digitalocean_volume.role-server.id, digitalocean_volume.tubbyland.id ]
  vpc_uuid = digitalocean_vpc.oinkcloud-sfo3.id

  ipv6 = true
  private_networking = true
  monitoring = true

  lifecycle {
    ignore_changes = [
      image
    ]
  }
  connection {
    type = "ssh"
    host = self.ipv4_address
    user = "root"
    private_key = var.tf_ssh_private_key
  }
  provisioner "remote-exec" {
    inline = [
      "ansible-playbook /root/OinkServer/ansible/mount-volumes.runtime.yml",
      "ansible-playbook -e 'mount_path=/mnt/role_server' /root/OinkServer/ansible/system-volume.runtime.yml"
    ]
  }
  // provisioner "file" {
  //   content = var.vault_unseal
  //   destination = "/mnt/role_server/terraform-persist/vault-unseal.json"
  // }
  // provisioner "file" {
  //   content = var.secret_writer
  //   destination = "/mnt/role_server/terraform-persist/secret-writer.json"
  // }
  provisioner "remote-exec" {
    inline = [
      "ansible-playbook -e 'mount_path=/mnt/role_server GCP_PROJECT=oinkserver' /root/OinkServer/ansible/role-server.runtime.yml",
      "ansible-playbook /root/OinkServer/ansible/role-client.runtime.yml"
    ]
  }
}

