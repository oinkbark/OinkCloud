resource "cloudflare_zone" "tubbyland" {
  zone = "tubbyland.com"
}

# WWW Redirect
resource "cloudflare_record" "tubbyland-www" {
  zone_id = cloudflare_zone.tubbyland.id
  type = "CNAME"
  name = "www"
  # cannot be @ or state is updated every time
  value = "tubbyland.com"
  proxied = true
}

# DNS Records
resource "cloudflare_record" "tubbyland-ui" {
  zone_id = cloudflare_zone.tubbyland.id
  type = "A"
  name = "@"
  value = var.tubbyland.proxy
  proxied = true
}
resource "cloudflare_record" "tubbyland-api" {
  zone_id = cloudflare_zone.tubbyland.id
  type = "A"
  name = "api"
  value = var.tubbyland.proxy
  proxied = true
}
resource "cloudflare_record" "tubbyland-developer" {
  zone_id = cloudflare_zone.tubbyland.id
  type = "CNAME"
  name = "developer"
  # cannot be @ or state is updated every time
  value = "api.tubbyland.com"
  proxied = true
}
resource "cloudflare_record" "tubbyland-preview" {
  zone_id = cloudflare_zone.tubbyland.id
  type = "A"
  name = "preview"
  value = var.tubbyland.proxy
  proxied = true
}
resource "cloudflare_record" "tubbyland-assets" {
  zone_id = cloudflare_zone.tubbyland.id
  type = "A"
  name = "assets"
  value = var.tubbyland.assets
  proxied = true
}

resource "cloudflare_authenticated_origin_pulls" "tubbyland" {
  zone_id = cloudflare_zone.tubbyland.id
  enabled = true
}

resource "cloudflare_zone_settings_override" "tubbyland" {
  zone_id = cloudflare_zone.tubbyland.id
    settings {
      # SSL/TLS
      ssl = "strict"
      min_tls_version = "1.2"
      always_use_https = "on"

      # Networking
      ipv6 = "on"
      http3 = "on"
      zero_rtt = "on"
      websockets = "on"
      opportunistic_onion = "on"

      # Speed
      brotli = "on"
      rocket_loader = "on"

      # Scrape Shield
      hotlink_protection = "on"

      minify {
        css = "off"
        js = "off"
        html = "off"
      }
    }
}
