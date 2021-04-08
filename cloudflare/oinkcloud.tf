resource "cloudflare_zone" "oinkcloud" {
  zone = "oinkcloud.com"
}

# WWW Redirect
resource "cloudflare_record" "oinkcloud-www" {
  zone_id = cloudflare_zone.oinkcloud.id
  type = "CNAME"
  name = "www"
  # cannot be @ or state is updated every time
  value = "oinkcloud.com"
  proxied = true
}
# TLS Certificate Provider
resource "cloudflare_record" "oinkcloud-tls" {
  zone_id = cloudflare_zone.oinkcloud.id
  type = "CAA"
  name = "@"
  data = {
    flags = "0"
    tag = "issue"
    value = "letsencrypt.org"
  }
}

# DNS Records
resource "cloudflare_record" "oinkcloud-root" {
  zone_id = cloudflare_zone.oinkcloud.id
  type = "A"
  name = "@"
  value = var.proxy_droplet
  proxied = true
}
resource "cloudflare_record" "oinkcloud-nomad" {
  zone_id = cloudflare_zone.oinkcloud.id
  type = "A"
  name = "nomad"
  value = var.proxy_droplet
  proxied = true
}
resource "cloudflare_record" "oinkcloud-vault" {
  zone_id = cloudflare_zone.oinkcloud.id
  type = "A"
  name = "vault"
  value = var.proxy_droplet
  proxied = true
}
// resource "cloudflare_record" "oinkcloud-vpn" {
//   zone_id = cloudflare_zone.oinkcloud.id
//   type = "A"
//   name = "vpn"
//   value = var.proxy_droplet
//   proxied = false
// }
// resource "cloudflare_record" "oinkcloud-region-us-sw" {
//   zone_id = cloudflare_zone.oinkcloud.id
//   type = "A"
//   name = "sw.us"
//   value = var.proxy_droplet
//   proxied = true
// }

resource "cloudflare_authenticated_origin_pulls" "oinkcloud" {
  zone_id = cloudflare_zone.oinkcloud.id
  enabled = true
}

resource "cloudflare_zone_settings_override" "oinkcloud" {
  zone_id = cloudflare_zone.oinkcloud.id
    settings {
      # SSL/TLS
      ssl = "strict"
      min_tls_version = "1.2"
      always_use_https = "on"

      # Networking
      ipv6 = "on"
      http3 = "on"
      # zrt must be enabled at same time as tls 1.3
      zero_rtt = "on"
      websockets = "on"
      opportunistic_onion = "on"

      # Speed
      brotli = "on"
      # Hashicorp JS will not load becuase of site src
      rocket_loader = "off"

      # Scrape Shield
      hotlink_protection = "on"

      minify {
        css = "off"
        js = "off"
        html = "off"
      }
    }
}
