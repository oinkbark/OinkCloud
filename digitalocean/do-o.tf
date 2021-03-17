output "role-server" {
  value = {
    ipv4 = digitalocean_droplet.role-server.ipv4_address
  }
}

output "tubbyland-assets" {
  value = digitalocean_droplet.role-server.ipv4_address
  // google_compute_global_address.tubbyland.address
}