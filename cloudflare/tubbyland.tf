resource "cloudflare_zone" "tubbyland" {
  zone = "tubbyland.com"
}

resource "cloudflare_record" "tubbyland-www" {
  zone_id = cloudflare_zone.tubbyland.id
  type = "CNAME"
  name = "www"
  # cannot be @ or state is updated every time
  value = "tubbyland.com"
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
