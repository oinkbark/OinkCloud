variable "tf_gcloud_credentials" {
  type = string
  sensitive = true
}

variable "digitalocean_token" {
  type = string
  sensitive = true
}
variable "ssh_public_keys" {
  type = string
  sensitive = true
}

// variable "packer_versions" {
//   default = {
//     packer = "1.7.4"
//     digitalocean = "1.0.1"
//   }
// }

variable "machine-img-downstream" {
  default = {
    base-deb10 = {
      parent = []
      children = [ "base-exec" ]
    }
    base-exec = {
      parent = [ "base-deb10" ]
      children = [ "role-server",  "role-client" ]
    }
    role-server = {
      parent = [ "base-exec" ]
      children = []
    }
    role-client = {
      parent = [ "base-exec" ]
      children = []
    }
    // role-monolith = {
    //   parent = [ "role-server", "role-client" ]
    //   children = []
    // }
    // role-dev = {
    //   parent = [ "base-exec" ]
    //   children = []
    // }
  }
}

variable "tubbyland-docker" {
  type = set(string)
  default = [
    "vue3",
    "graphql",
    "cypress"
  ]
}

variable "oinkserver_domain_link" {
  type = string
}
variable "oinkserver_observe_account" {
  type = string
}
