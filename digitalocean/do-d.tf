data "digitalocean_droplet_snapshot" "role-server" {
  name_regex = "role-server"
  most_recent = "true"
  region = var.cluster.region.provider
}
data "digitalocean_droplet_snapshot" "role-client" {
  name_regex = "role-client"
  most_recent = "true"
  region = var.cluster.region.provider
}


// data "digitalocean_droplet_snapshot" "role-agent" {
//   name_regex = "role-agent"
//   most_recent = "true"
//   region = var.cluster.region
// }
// data "digitalocean_droplet_snapshot" "role-dev" {
//   name_regex = "role-dev"
//   most_recent = "true"
//   region = var.cluster.region
// }