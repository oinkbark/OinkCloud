resource "digitalocean_project" "oinkcloud" {
  name        = "OinkCloud"
  description = "OinkCloud Central Operations"
  purpose     = "Web Application"
  environment = "Production"
  resources = flatten([
    [
      digitalocean_volume.tubbyland.urn,
      digitalocean_volume.nw-us-volume.urn,
      digitalocean_volume.nw-us-leader.urn,

      digitalocean_droplet.nw-us-server.urn,
      digitalocean_droplet.nw-us-leader.urn,
    ],
    [
      for key, val in digitalocean_droplet.nw-us-worker : val.urn
    ]
  ])
}

resource "digitalocean_vpc" "oinkcloud-sfo3" {
  name = "oinkcloud-sfo3"
  region = var.cluster.region.provider
}

# Volumes
resource "digitalocean_volume" "tubbyland" {
  region = var.cluster.region.provider
  name = "tubbyland"
  size = 3
  initial_filesystem_type = "xfs"
}
resource "digitalocean_volume" "nw-us-volume" {
  region = var.cluster.region.provider
  name = "nw-us-volume"
  size = 3
  initial_filesystem_type = "xfs"
}
resource "digitalocean_volume" "nw-us-leader" {
  region = var.cluster.region.provider
  name = "nw-us-leader"
  size = 1
  initial_filesystem_type = "xfs"
}
// resource "digitalocean_volume" "nw-us-tubbyland" {
//   region = var.cluster.region.provider
//   name = "nw-us-volume"
//   size = 3
//   initial_filesystem_type = "xfs"
// }

# Droplets

# If there is only one server, resource target will have to be used to recreate it
## Otherwise, references to the vault and nomad server address will fail upon refresh
resource "digitalocean_droplet" "nw-us-server" {
  # for_each = var.cluster.deployment.server

  name   = "nw-us-server"
  # size   = each.value.size
  size = "s-1vcpu-1gb"
  region = var.cluster.region.provider

  image  = data.digitalocean_droplet_snapshot.role-server.id
  volume_ids = [ digitalocean_volume.nw-us-volume.id ]
  vpc_uuid = digitalocean_vpc.oinkcloud-sfo3.id
  tags = [
    "nw-us",
    "server",
    "nw-us-server"
  ]

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
      "ansible-playbook -e 'mount_path=/mnt/nw_us_volume' /root/OinkServer/ansible/system-volume.runtime.yml"
    ]
  }
  # We do not want to copy these because they already exist from the origin boot
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
      "ansible-playbook -e 'oinkcloud_region=${var.cluster.region.oinkcloud} mount_path=/mnt/nw_us_volume GCP_PROJECT=oinkserver' /root/OinkServer/ansible/role-server.runtime.yml",
    ]
  }
}
resource "digitalocean_droplet" "nw-us-leader" {
  # for_each = var.cluster.deployment.leader

  name   = "nw-us-leader"
  # size   = each.value.size
  size = "s-1vcpu-1gb"
  region = var.cluster.region.provider
  tags = [
    "nw-us",
    "client",
    "client-leader",
    "nw-us-client-leader"
  ]

  image = data.digitalocean_droplet_snapshot.role-client.id
  volume_ids = [ digitalocean_volume.nw-us-leader.id, digitalocean_volume.tubbyland.id ]
  vpc_uuid = digitalocean_vpc.oinkcloud-sfo3.id

  ipv6 = true
  private_networking = true
  monitoring = true

  lifecycle {
    ignore_changes = [
      image
    ]
  }
}
# Vault must have the IP before it can create the TLS CSR
## The provisioning is disconnected to prevent a dependency loop
## Error: Cycle: module.vault.vault_pki_secret_backend_cert.leader (destroy), module.digitalocean.digitalocean_droplet.nw-us-leader (destroy), module.digitalocean.digitalocean_droplet.nw-us-leader, module.digitalocean.output.nw-us (expand), module.vault.var.address (expand), module.vault.provider["registry.terraform.io/hashicorp/vault"]
resource "null_resource" "nw-us-leader" {
  #for_each = var.cluster.deployment.leader
  depends_on = [ digitalocean_droplet.nw-us-leader ]

  connection {
    type = "ssh"
    host = digitalocean_droplet.nw-us-leader.ipv4_address
    user = "root"
    private_key = var.tf_ssh_private_key
  }
  provisioner "file" {
    content = var.vault_client.nw-us.ca-crt
    destination ="/root/OinkServer/runtime/server.dc1.consul-ca.crt"
  }
  provisioner "file" {
    content = var.vault_client.nw-us.tls-crt.leader
    destination = "/root/OinkServer/runtime/vault-client.consul-tls.crt"
  }
  provisioner "file" {
    content = var.vault_client.nw-us.tls-key.leader
    destination = "/root/OinkServer/runtime/vault-client.consul-tls.key"
  }
  provisioner "file" {
    content = var.consul_digitalocean_token
    destination = "/root/OinkServer/runtime/consul_digitalocean_token"
  }
  provisioner "remote-exec" {
    inline = [
      "ansible-playbook -e 'mount_path=/mnt/nw_us_leader oinkcloud_region=${var.cluster.region.oinkcloud} provider_region=${var.cluster.region.provider} provider_token_path=/root/OinkServer/runtime/consul_digitalocean_token GCP_PROJECT=oinkserver' /root/OinkServer/ansible/role-client.leader.runtime.yml"
    ]
  }
}

# for_each does not destroy existing resources
resource "digitalocean_droplet" "nw-us-worker" {
  for_each = tomap(var.cluster.deployment.worker)

  name   = "nw-us-worker-${each.key}"
  size   = each.value.size
  region = var.cluster.region.provider
  tags = [
    "nw-us",
    "client",
    "worker",
  ]

  image = data.digitalocean_droplet_snapshot.role-client.id
  vpc_uuid = digitalocean_vpc.oinkcloud-sfo3.id

  ipv6 = true
  private_networking = true
  monitoring = true

  lifecycle {
    ignore_changes = [
      image
    ]
  }
}
resource "null_resource" "nw-us-worker" {
  depends_on = [ digitalocean_droplet.nw-us-worker ]
  for_each = var.cluster.deployment.worker

  connection {
    type = "ssh"
    host = digitalocean_droplet.nw-us-worker[each.key].ipv4_address
    user = "root"
    private_key = var.tf_ssh_private_key
  }
  provisioner "file" {
    content = var.vault_client.nw-us.ca-crt
    destination ="/root/OinkServer/runtime/server.dc1.consul-ca.crt"
  }
  provisioner "file" {
    content = var.vault_client.nw-us.tls-crt.worker[each.key]
    destination = "/root/OinkServer/runtime/vault-client.consul-tls.crt"
  }
  provisioner "file" {
    content = var.vault_client.nw-us.tls-key.worker[each.key]
    destination = "/root/OinkServer/runtime/vault-client.consul-tls.key"
  }
  provisioner "file" {
    content = var.vault_client.nw-us.tls-crt.worker-service[each.key]
    destination = "/root/OinkServer/runtime/worker-service.consul-tls.crt"
  }
  provisioner "file" {
    content = var.vault_client.nw-us.tls-key.worker-service[each.key]
    destination = "/root/OinkServer/runtime/worker-service.consul-tls.key"
  }
  provisioner "file" {
    content = var.consul_digitalocean_token
    destination = "/root/OinkServer/runtime/consul_digitalocean_token"
  }
  provisioner "remote-exec" {
    inline = [
      "ansible-playbook -e 'oinkcloud_region=${var.cluster.region.oinkcloud} provider_region=${var.cluster.region.provider} provider_token_path=/root/OinkServer/runtime/consul_digitalocean_token GCP_PROJECT=oinkserver' /root/OinkServer/ansible/role-client.worker.runtime.yml"
    ]
  }
}

// # Server count is to be stored in vault secret
// # https://www.terraform.io/docs/cloud/api/run.html
// # The job that watches usage metrics sends a post request to tf to queue a run & apply
// # The secret value is automatically checked
// # The leader server will need to generate certs and store them in vault
// # and this resource will need to provision that file with count.index from vault

// resource "digitalocean_droplet" "nw-us-worker" {
//   count = var.cluster.worker_count || 1

//   name   = "nw-us-worker"
//   size   = "s-1vcpu-1gb"
//   region = var.cluster.region.provider
//   tags = [
//     "nw-us",
//     "client",
//     "client-worker",
//     "nw-us-client-worker"
//   ]

//   image  = data.digitalocean_droplet_snapshot.role-client.id
//   vpc_uuid = digitalocean_vpc.oinkcloud-sfo3.id

//   ipv6 = true
//   private_networking = true
//   monitoring = true

//   lifecycle {
//     ignore_changes = [
//       image
//     ]
//   }
//   connection {
//     type = "ssh"
//     host = self.ipv4_address
//     user = "root"
//     private_key = var.tf_ssh_private_key
//   }
//   provisioner "file" {
//     content = var.vault_ca
//     destination ="/root/OinkServer/runtime/server.dc1.consul-ca.crt"
//   }
//   provisioner "file" {
//     content = var.vault_tls_cert.worker[count.index]
//     destination = "/root/OinkServer/runtime/vault-agent.consul-tls.crt"
//   }
//   provisioner "file" {
//     content = var.vault_tls_key.worker[count.index]
//     destination = "/root/OinkServer/runtime/vault-agent.consul-tls.key"
//   }
//   provisioner "remote-exec" {
//     inline = [
//       "ansible-playbook -e 'oinkcloud_region=${var.cluster.region.oinkcloud} provider_region=${var.cluster.region.provider} provider_token=${var.consul_digitalocean_token} mount_path=/root GCP_PROJECT=oinkserver' /root/OinkServer/ansible/role-client.worker.runtime.yml"
//     ]
//   }
// }
