# System
resource "nomad_job" "proxy" {
  jobspec = templatefile(data.local_file.job-proxy.filename, {
    TEMPLATE_NGINX = data.local_file.proxy-nginx.content,
    TEMPLATE_INCLUDES = data.local_file.proxy-includes.content,
    TEMPLATE_HTTP = data.local_file.proxy-http.content,
    TEMPLATE_STREAM = data.local_file.proxy-stream.content,
    TEMPLATE_ORIGIN_PULL = data.local_file.proxy-origin-pull.content,
    TEMPLATE_CERT_MOUNT = "/mnt/nw_us_leader/etc/letsencrypt",
    TEMPLATE_CA_BUNDLE = var.vault_ca_bundle
  })

  hcl2 {
    enabled  = true
    allow_fs = false
  }
}

# OinkBark
resource "nomad_job" "oinkbark-ssl" {
  jobspec = templatefile("${path.module}/templates/terraform/job-ssl.hcl", {
    DOMAIN_NAME = "oinkbark",
    DOMAIN_TLD = "com"
  })

  hcl2 {
    enabled  = true
    allow_fs = true
  }
}

// # OinkCloud
resource "nomad_job" "oinkcloud-ssl" {
  jobspec = templatefile("${path.module}/templates/terraform/job-ssl.hcl", {
    DOMAIN_NAME = "oinkcloud",
    DOMAIN_TLD = "com"
  })

  hcl2 {
    enabled  = true
    allow_fs = true
  }
}
resource "nomad_job" "oinkcloud-ssl-direct" {
  jobspec = templatefile("${path.module}/templates/terraform/job-subdomain-ssl.hcl", {
    SUBDOMAIN_NAME = "direct",
    DOMAIN_NAME = "oinkcloud",
    DOMAIN_TLD = "com"
  })

  hcl2 {
    enabled  = true
    allow_fs = true
  }
}
resource "nomad_job" "ops-db" {
  jobspec = templatefile(data.local_file.job-ops-db.filename, {
    NEO4J_PASSWORD = var.vault_ops_db.root_password
  })

  hcl2 {
    enabled  = true
    allow_fs = false
  }
}
// resource "nomad_job" "rtc-db" {
//   jobspec = templatefile(data.local_file.job-rtc-db.filename, {
//     MYSQL_PASSWORD = var.vault_rtc_db.root_password
//   })

//   hcl2 {
//     enabled  = true
//     allow_fs = false
//   }
// }

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
// resource "nomad_job" "tubbyland-db" {
//   jobspec = templatefile(data.local_file.job-tubbyland-db.filename, {
//     MONGO_USERNAME = var.vault_tubbyland_db.root_username,
//     MONGO_PASSWORD = var.vault_tubbyland_db.root_password,
//     TEMPLATE_REDIS = data.local_file.tubbyland-db-redis.content
//   })
//   # TEMPLATE_MONGO = data.local_file.tubbyland-db-mongo.content

//   hcl2 {
//     enabled  = true
//     allow_fs = false
//   }
// }
// resource "nomad_job" "tubbyland-api" {
//   jobspec = templatefile(data.local_file.job-tubbyland-api.filename, {
//     TEMPLATE_SECRET_DB = data.local_file.tubbyland-api-secret-db.content,
//     TEMPLATE_SECRET_BUCKET_MANAGER = data.local_file.tubbyland-api-secret-bucket-manager.content,
//     TEMPLATE_SECRET_OBJECT_ADMIN = data.local_file.tubbyland-api-secret-object-admin.content,
//     TEMPLATE_SECRET_OAUTH_EMAILS = data.local_file.tubbyland-api-secret-emails.content,
//     TEMPLATE_SECRET_OAUTH_GCP = data.local_file.tubbyland-api-secret-oauth-gcp.content,
//     TEMPLATE_SECRET_OAUTH_INTERNAL = data.local_file.tubbyland-preview-secret-oauth-internal.content
//   })

//   hcl2 {
//     enabled  = true
//     allow_fs = false
//   }
// }
resource "nomad_job" "tubbyland-ui" {
  jobspec = data.local_file.job-tubbyland-ui.content

  hcl2 {
    enabled  = true
    allow_fs = false
  }
}
## Preview
// resource "nomad_job" "tubbyland-preview-ui" {
//   jobspec = data.local_file.job-tubbyland-preview-ui.content

//   hcl2 {
//     enabled  = true
//     allow_fs = false
//   }
// }
// resource "nomad_job" "tubbyland-preview-api" {
//   jobspec = templatefile(data.local_file.job-tubbyland-preview-api.filename, {
//     TEMPLATE_SECRET_DB = data.local_file.tubbyland-api-secret-db.content,
//     TEMPLATE_SECRET_BUCKET_MANAGER = data.local_file.tubbyland-api-secret-bucket-manager.content,
//     TEMPLATE_SECRET_OBJECT_ADMIN = data.local_file.tubbyland-api-secret-object-admin.content,
//     TEMPLATE_SECRET_OAUTH_EMAILS = data.local_file.tubbyland-api-secret-emails.content,
//     TEMPLATE_SECRET_OAUTH_GCP = data.local_file.tubbyland-api-secret-oauth-gcp.content,
//     TEMPLATE_SECRET_OAUTH_INTERNAL = data.local_file.tubbyland-preview-secret-oauth-internal.content
//   })

//   hcl2 {
//     enabled  = true
//     allow_fs = false
//   }
// }

// # TEMPLATE_PROM = data.local_file.observe-prom.content
// resource "nomad_job" "observe" {
//   jobspec = templatefile(data.local_file.job-observe.filename, {
//     TEMPLATE_FLUENT = data.local_file.observe-fluent.content
//   })

//   hcl2 {
//     enabled  = true
//     allow_fs = false
//   }
// }
