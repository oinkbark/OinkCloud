##############
### System ###
##############

variable "tf_nomad_root" {
  type = string
  sensitive = true
}
variable "tf_vault_root" {
  type = string
  sensitive = true
}
variable "address" {
  type = string
}

# Vault
// variable "vault_oinkserver_registry" {
// }
variable "vault_tubbyland_db" {
}
variable "vault_rtc_db" {
}
variable "vault_ops_db" {
}
variable "vault_ca_bundle" {
  type = string
  sensitive = true
}


#############
### Sites ###
#############

// variable "tubbyland" {
//   sensitive = true
//   type = object({
//     mongo = object({
//       root_username = string
//       root_password = string
//     })
//   })
// }