resource "vault_policy" "oinkserver-client" {
  name = "oinkserver-client"
  policy = file("${path.module}/policies/oinkserver-client.hcl")
}
resource "vault_policy" "gcloud-consumer" {
  name = "gcloud-consumer"
  policy = file("${path.module}/policies/gcloud-consumer.hcl")
}
resource "vault_policy" "tubbyland-consumer" {
  name = "tubbyland-consumer"
  policy = file("${path.module}/policies/tubbyland-consumer.hcl")
}

# Backends
## * googleapi: Error 400: Precondition check failed., failedPrecondition
## Above error will occur when 10 service account keys exist
resource "vault_gcp_secret_backend" "gcp" {
  credentials = var.secrets_gcp
  default_lease_ttl_seconds = (24 * 3600)
  max_lease_ttl_seconds = (48 * 3600)
}
resource "vault_gcp_auth_backend" "gcp" {
  credentials = var.auth_gcp
}
resource "vault_auth_backend" "cert" {
  path = "cert"
  type = "cert"
}

# Would be used by Vault Clients (vault agent auto auth)
// resource "vault_gcp_auth_backend_role" "gcloud-consumer" {
//   backend = vault_auth_backend.gcp.path
//   bound_projects = [ local.project ]
//   bound_service_accounts = "*"
//   token_policies = [ "gcloud-consumer" ]
// }
# vault read auth/cert/certs/vault-client
resource "vault_cert_auth_backend_role" "vault-client" {
  name = "vault-client"
  certificate = var.auth_ca_crt
  backend = vault_auth_backend.cert.path
  #allowed_common_names = ["service.consul"]
  token_policies = ["oinkserver-client", "gcloud-consumer", "tubbyland-consumer"]
}

# GCP Secret Backend Rolesets
## Depends on iam member being set
## Vault read will fail with "* googleapi: Error 400: Precondition check failed., failedPrecondition"
## when 10 account keys already exist
resource "vault_gcp_secret_roleset" "registry-reader" {
  backend = vault_gcp_secret_backend.gcp.path
  roleset = "registry-reader"
  secret_type = "service_account_key"
  project = "oinkserver"

  binding {
    resource = "projects/oinkserver"

    roles = [
      "roles/storage.objectViewer",
    ]
  }
}
resource "vault_gcp_secret_roleset" "observe-writer" {
  backend = vault_gcp_secret_backend.gcp.path
  roleset = "observe-writer"
  secret_type = "service_account_key"
  project = "oinkserver"

  binding {
    resource = "projects/oinkserver"

    roles = [
      "roles/logging.logWriter",
      "roles/logging.bucketWriter",
      "roles/monitoring.metricWriter"
    ]
  }
}
resource "vault_gcp_secret_roleset" "bucket-manager" {
  backend = vault_gcp_secret_backend.gcp.path
  roleset = "bucket-manager"
  secret_type = "service_account_key"
  project = "tubbyland"

  binding {
    resource = "projects/tubbyland"

    roles = [
      "projects/tubbyland/roles/bucket_manager"
    ]
  }
}
resource "vault_gcp_secret_roleset" "object-admin" {
  backend = vault_gcp_secret_backend.gcp.path
  roleset = "object-admin"
  secret_type = "service_account_key"
  project = "tubbyland"

  binding {
    resource = "projects/tubbyland"

    # only create tokens for its own service account
    roles = [
      "roles/storage.objectAdmin",
      "roles/iam.serviceAccountTokenCreator",
    ]
  }
}

resource "vault_mount" "kv2" {
  path = "secret"
  type = "kv-v2"
  # past, present, future
  // options = {
  //   max_versions = 3
  // }
}

resource "vault_generic_secret" "oinkserver-terraform" {
  path = "secret/oinkserver/terraform"
  data_json = jsonencode(var.terraform)
}
resource "vault_generic_secret" "oinkserver-packer" {
  path = "secret/oinkserver/packer"
  data_json = jsonencode(var.packer)
}
resource "vault_generic_secret" "oinkserver-domains" {
  path = "secret/oinkserver/domains"
  data_json = file("${path.module}/domains.json")
}  

# Tubbyland
resource "vault_generic_secret" "tubbyland-oauth" {
  path = "secret/tubbyland/oauth"
  data_json = jsonencode({
    emails: var.nomad.tubbyland_oauth_emails
    gcp: base64encode(var.nomad.tubbyland_oauth_gcp)
  })
}
resource "vault_generic_secret" "tubbyland-dns-cloudflare" {
  path = "secret/tubbyland/dns"
  data_json = jsonencode({
    certbot: var.nomad.dns_certbot_token
  })
}
resource "vault_generic_secret" "tubbyland-db" {
  path = "secret/tubbyland/db"
  data_json = jsonencode({
    root_username: var.nomad.tubbyland_db_username
    root_password: var.nomad.tubbyland_db_password
  })
}
