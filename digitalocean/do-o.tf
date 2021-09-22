# These must be separate variables
# Otherwise, Terraform creates cycle errors when a nested object is updated
# Ex: leader IP changes = server IP cannot be referenced (because both are in the same parent variable)
output "nw-us-server" {
  value = {
    ipv4 = digitalocean_droplet.nw-us-server.ipv4_address
    ipv4-private = digitalocean_droplet.nw-us-server.ipv4_address_private
  }
}
output "nw-us-leader" {
  value = {
    ipv4 = digitalocean_droplet.nw-us-leader.ipv4_address
    ipv4-private = digitalocean_droplet.nw-us-leader.ipv4_address_private
  }
}
output "nw-us-worker" {
  // ipv4_address
  // ipv4_address_private
  value = {
    for key, val in digitalocean_droplet.nw-us-worker : key => { 
      ipv4: val.ipv4_address,
      ipv4-private: val.ipv4_address_private
    }
  }
  
  #  digitalocean_droplet.nw-us-worker
  # value = {
  #   ipv4 = { for key, val in digitalocean_droplet.nw-us-worker : key => val.ipv4_address }
  #   ipv4-private = { for key, val in digitalocean_droplet.nw-us-worker : key => val.ipv4_address_private }
  # }
  # value = {
  #   ipv4 = digitalocean_droplet.nw-us-worker.ipv4_address
  #   ipv4-private = digitalocean_droplet.nw-us-worker.ipv4_address_private
  # }
}
output "tubbyland-assets" {
  value = digitalocean_droplet.nw-us-leader.ipv4_address
  // google_compute_global_address.tubbyland.address
}