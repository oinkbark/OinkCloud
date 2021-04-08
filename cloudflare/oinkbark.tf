resource "cloudflare_zone" "oinkbark" {
  zone = "oinkbark.com"
}

# WWW Redirect
resource "cloudflare_record" "www" {
  zone_id = cloudflare_zone.oinkbark.id
  type = "CNAME"
  name = "www"
  # cannot be @ or state is updated every time
  value = "oinkbark.com"
  proxied = true
}

resource "cloudflare_record" "proxy" {
  zone_id = cloudflare_zone.oinkbark.id
  type = "A"
  name = "@"
  value = var.proxy_droplet
  proxied = true
}

# TLS Certificate Provider
## https://community.letsencrypt.org/t/beginning-issuance-from-r3/139018
resource "cloudflare_record" "letsencrypt" {
  zone_id = cloudflare_zone.oinkbark.id
  type = "CAA"
  name = "@"
  data = {
    flags = "0"
    tag = "issue"
    value = "letsencrypt.org"
  }
}
// resource "cloudflare_record" "letsencrypt" {
//   zone_id = cloudflare_zone.oinkbark.id
//   type = "CAA"
//   name = "@"
//   data = {
//     flags = "0"
//     tag = "issuewild"
//     value = "letsencrypt.org"
//   }
// }

resource "cloudflare_record" "google-site-verification" {
  zone_id = cloudflare_zone.oinkbark.id
  type = "TXT"
  name = "@"
  value = "google-site-verification=p-VyBhG9BwTW45NF1P7JGFeU6gAi6zAxaJdVPCIeyVg"
}
resource "cloudflare_record" "google-cname" {
  zone_id = cloudflare_zone.oinkbark.id
  type = "CNAME"
  name = "2vjubwj3furg"
  value = "gv-h3ztsycpeiyhxj.dv.googlehosted.com"
}

// resource "cloudflare_authenticated_origin_pulls" "my_aop" {
//   zone_id = var.cloudflare_zone_id
//   enabled = true
// }

resource "cloudflare_zone_settings_override" "oinkbark" {
  zone_id = cloudflare_zone.oinkbark.id
    settings {
      # SSL/TLS
      #ssl = "origin_pull"
      #ssl = "strict"
      #tls_1_3 = "on"
      #min_tls_version = "1.2"
      #always_use_https = "on"

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
