# Tubbyland
## Production
resource "nomad_job" "tubbyland-ssl" {
  jobspec = templatefile("${path.module}/templates/terraform/job-ssl.hcl", {
    DOMAIN_NAME = "tubbyland",
    DOMAIN_TLD = "com"
  })

  hcl2 {
    enabled  = true
    allow_fs = true
  }
}
resource "nomad_job" "tubbyland-db" {
  jobspec = templatefile(data.local_file.job-tubbyland-db.filename, {
    MONGO_USERNAME = var.vault_tubbyland_db.root_username,
    MONGO_PASSWORD = var.vault_tubbyland_db.root_password,
    TEMPLATE_REDIS = data.local_file.tubbyland-db-redis.content
  })

  hcl2 {
    enabled  = true
    allow_fs = false
  }
}
resource "nomad_job" "tubbyland-api" {
  jobspec = templatefile(data.local_file.job-tubbyland-api.filename, {
    TEMPLATE_SECRET_DB = data.local_file.tubbyland-api-secret-db.content,
    TEMPLATE_SECRET_BUCKET_MANAGER = data.local_file.tubbyland-api-secret-bucket-manager.content,
    TEMPLATE_SECRET_OBJECT_ADMIN = data.local_file.tubbyland-api-secret-object-admin.content,
    TEMPLATE_SECRET_OAUTH_EMAILS = data.local_file.tubbyland-api-secret-emails.content,
    TEMPLATE_SECRET_OAUTH_GCP = data.local_file.tubbyland-api-secret-oauth-gcp.content,
    TEMPLATE_SECRET_OAUTH_INTERNAL = data.local_file.tubbyland-preview-secret-oauth-internal.content
  })

  hcl2 {
    enabled  = true
    allow_fs = false
  }
}
resource "nomad_job" "tubbyland-ui" {
  jobspec = data.local_file.job-tubbyland-ui.content

  hcl2 {
    enabled  = true
    allow_fs = false
  }
}
## Preview
resource "nomad_job" "tubbyland-preview-ui" {
  jobspec = data.local_file.job-tubbyland-preview-ui.content

  hcl2 {
    enabled  = true
    allow_fs = false
  }
}
resource "nomad_job" "tubbyland-preview-api" {
  jobspec = templatefile(data.local_file.job-tubbyland-preview-api.filename, {
    TEMPLATE_SECRET_DB = data.local_file.tubbyland-api-secret-db.content,
    TEMPLATE_SECRET_BUCKET_MANAGER = data.local_file.tubbyland-api-secret-bucket-manager.content,
    TEMPLATE_SECRET_OBJECT_ADMIN = data.local_file.tubbyland-api-secret-object-admin.content,
    TEMPLATE_SECRET_OAUTH_EMAILS = data.local_file.tubbyland-api-secret-emails.content,
    TEMPLATE_SECRET_OAUTH_GCP = data.local_file.tubbyland-api-secret-oauth-gcp.content,
    TEMPLATE_SECRET_OAUTH_INTERNAL = data.local_file.tubbyland-preview-secret-oauth-internal.content
  })

  hcl2 {
    enabled  = true
    allow_fs = false
  }
}

# System
resource "nomad_job" "proxy" {
  jobspec = templatefile(data.local_file.job-proxy.filename, {
    TEMPLATE_NGINX = data.local_file.proxy-nginx.content,
    TEMPLATE_INCLUDES = data.local_file.proxy-includes.content,
    TEMPLATE_SITES = data.local_file.proxy-sites.content,
    TEMPLATE_ORIGIN_PULL = data.local_file.proxy-origin-pull.content
  })

  hcl2 {
    enabled  = true
    allow_fs = false
  }

}
# TEMPLATE_PROM = data.local_file.observe-prom.content
resource "nomad_job" "observe" {
  jobspec = templatefile(data.local_file.job-observe.filename, {
    TEMPLATE_FLUENT = data.local_file.observe-fluent.content
  })

  hcl2 {
    enabled  = true
    allow_fs = false
  }
}
