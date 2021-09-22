############
### Jobs ###
############

# System
data "local_file" "job-proxy" {
  filename = "${path.module}/templates/terraform/job-proxy.hcl"
}
data "local_file" "job-observe" {
  filename = "${path.module}/templates/terraform/job-observe.hcl"
}
# OinkCloud
data "local_file" "job-ops-db" {
  filename = "${path.module}/templates/terraform/ops-db.hcl"
}
// data "local_file" "job-rtc-db" {
//   filename = "${path.module}/templates/terraform/rtc-db.hcl"
// }
# Tubbyland
## Production
data "local_file" "job-tubbyland-api" {
  filename = "${path.module}/templates/terraform/tubbyland-api.hcl"
}
data "local_file" "job-tubbyland-db" {
  filename = "${path.module}/templates/terraform/tubbyland-db.hcl"
}
data "local_file" "job-tubbyland-ui" {
  filename = "${path.module}/templates/terraform/tubbyland-ui.hcl"
}
## Preview
data "local_file" "job-tubbyland-preview-ui" {
  filename = "${path.module}/templates/terraform/tubbyland-preview-ui.hcl"
}
data "local_file" "job-tubbyland-preview-api" {
  filename = "${path.module}/templates/terraform/tubbyland-preview-api.hcl"
}

######################
### Template Files ###
######################

# Proxy
data "local_file" "proxy-nginx" {
  filename = "${path.module}/templates/nginx/nginx.conf"
}
data "local_file" "proxy-includes" {
  filename = "${path.module}/templates/nginx/includes/includes.conf"
}
data "local_file" "proxy-http" {
  filename = "${path.module}/templates/nginx/includes/sites-available.conf.ctmpl"
}
data "local_file" "proxy-stream" {
  filename = "${path.module}/templates/nginx/includes/stream.conf.ctmpl"
}
data "local_file" "proxy-origin-pull" {
  filename = "${path.module}/templates/nginx/includes/certs/cloudflare-origin-pull.pem"
}

# Observability
data "local_file" "observe-fluent" {
  filename = "${path.module}/templates/fluentd/fluent.conf"
}
// data "local_file" "observe-prom" {
//   filename = "${path.module}/templates/prometheus/prom.yml"
// }

# Tubbyland API
data "local_file" "tubbyland-api-secret-bucket-manager" {
  filename = "${path.module}/templates/secrets/tubbyland-api/bucket-manager.json.ctmpl"
}
data "local_file" "tubbyland-api-secret-object-admin" {
  filename = "${path.module}/templates/secrets/tubbyland-api/object-admin.json.ctmpl"
}
data "local_file" "tubbyland-api-secret-db" {
  filename = "${path.module}/templates/secrets/tubbyland-api/db.json.ctmpl"
}
data "local_file" "tubbyland-api-secret-emails" {
  filename = "${path.module}/templates/secrets/tubbyland-api/emails.json.ctmpl"
}
data "local_file" "tubbyland-api-secret-oauth-gcp" {
  filename = "${path.module}/templates/secrets/tubbyland-api/oauth-gcp.json.ctmpl"
}

# Tubbyland DB
data "local_file" "tubbyland-db-redis" {
  filename = "${path.module}/templates/redis/redis.conf"
}
// data "local_file" "tubbyland-db-mongo" {
//   filename = "${path.module}/templates/mongo/mongod.conf"
// }

# Tubbyland Preview
data "local_file" "tubbyland-preview-secret-oauth-internal" {
  filename = "${path.module}/templates/secrets/tubbyland-preview/internal.json.ctmpl"
}
