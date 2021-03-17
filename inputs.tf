#################
### Terraform ###
#################

variable "tf_digitalocean_token" {
  type = string
  sensitive = true
}
variable "tf_gcloud_credentials" {
  type = string
  sensitive = true
}
variable "tf_ssh_private_key" {
  type = string
  sensitive = true
}
# All zones - Zone Settings:Edit, Zone:Edit, SSL and Certificates:Edit, DNS:Edit
variable "tf_cloudflare_token" {
  type = string
  sensitive = true
}


##############
### Packer ###
##############

variable "digitalocean_token" {
  type = string
  sensitive = true
}
## This MUST contain the public key of the tf_ssh_private_key
variable "ssh_public_keys" {
  type = string
  sensitive = true
}


#############
### Nomad ###
#############

# Certbot
## All zones - DNS:Edit
## Adds and removes TXT record to complete dns-01 challenge
variable "dns_certbot_token" {
  type = string
}
# Must be marked as "HCL" variable
variable "tubbyland_oauth_emails_whitelist" {
  type = list(string)
}
variable "tubbyland_oauth_gcp_credentials" {
  type = string
}


variable "tubbyland_db_username" {
  type = string
}

