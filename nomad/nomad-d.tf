############
### Jobs ###
############

data "local_file" "job-proxy" {
  filename = "${path.module}/templates/terraform/job-proxy.hcl"
}
data "local_file" "job-observe" {
  filename = "${path.module}/templates/terraform/job-observe.hcl"
}
data "local_file" "job-tubbyland-api" {
  filename = "${path.module}/templates/terraform/tubbyland-api.hcl"
}
data "local_file" "job-tubbyland-db" {
  filename = "${path.module}/templates/terraform/tubbyland-db.hcl"
}
data "local_file" "job-tubbyland-ui" {
  filename = "${path.module}/templates/terraform/tubbyland-ui.hcl"
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
data "local_file" "proxy-sites" {
  filename = "${path.module}/templates/nginx/includes/sites-available.conf.ctmpl"
}
data "local_file" "proxy-origin-pull" {
  filename = "${path.module}/templates/nginx/includes/cloudflare-origin-pull.pem"
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
