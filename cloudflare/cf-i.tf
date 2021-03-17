variable "tf_cloudflare_token" {
}
variable "proxy_droplet" {
}
variable "tubbyland" {
  type = object({
    domain_name = string
    domain_tld = string
    proxy = string
    assets = string
  })
}