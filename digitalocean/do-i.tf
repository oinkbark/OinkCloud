variable "tf_digitalocean_token" {
  type = string
  sensitive = true
}
variable "tf_ssh_private_key" {
  type = string
  sensitive = true
}
variable "cluster" {
  default = {
    region = "sfo3"
    server_count = 1
    client_count = 1
  }
}
variable "vault_unseal" {
  type = string
  #sensitive = true
}
variable "secret_writer" {
  type = string
  #sensitive = true
}