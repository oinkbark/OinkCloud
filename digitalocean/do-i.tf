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
    region = {
      oinkcloud = "nw-us"
      provider = "sfo3"
    }
    # Will eventually use a separate function that takes (min: 1, max: 4) variables to generate the values for these arrays
    deployment = {
      server = { "1": { size: "s-1vcpu-1gb" } }
      leader = { "1": { size: "s-1vcpu-1gb" } }
      worker = { "1": { size: "s-2vcpu-4gb", generation: 1 } }
    }
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

# Multi-server & autoscaling
variable "consul_digitalocean_token" {
  type = string
  #sensitive = true
}

variable "vault_client" {
  type = object({
    nw-us = object({
      ca-crt = string
      tls-crt = object({
        leader = string,
        worker = map(any)
        worker-service = map(any)
      })
      tls-key = object({
        leader = string
        worker = map(any)
        worker-service = map(any)
      })
    })
  })
}

// variable "vault_ca" {
//   type = string
// }
// variable "vault_tls_cert" {
//   type = object({
//     leader = string
//     worker = list(string)
//   })
// }
// variable "vault_tls_key" {
//   type = object({
//     leader = string
//     worker = list(string)
//   })
// }