# KV2 path requires "secret/data/" prefix
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
resource "vault_policy" "nomad-client" {
  name = "nomad-client"
  policy = file("${path.module}/policies/nomad-client.hcl")
}

resource "vault_mount" "kv2" {
  path = "secret"
  type = "kv-v2"
  # past, present, future
  // options = {
  //   max_versions = 3
  // }
}
resource "vault_mount" "pki" {
  path = "cert"
  type = "pki"

  # Cannot be greater than expiration of CA Cert
  # which means this needs to have a rolling default that constantly decreases
  default_lease_ttl_seconds = (9 * 365 * 86400)
  max_lease_ttl_seconds = (9 * 365 * 86400)

  // options = {
  //   ca = {
  //     pem_bundle = templatefile("nw-us-vault/data/ca.pem", {
  //       PUBLIC_CRT = var.secrets_pki_ca_crt,
  //       PRIVATE_KEY = var.secrets_pki_ca_key
  //     })
  //   }
  // }
}

// <<EOF
// ${var.secrets_pki_ca_crt}
// ${var.secrets_pki_ca_key}
// EOF
// resource "vault_pki_secret_backend_config_ca" "pki" {
//   backend = vault_mount.pki.path
//   pem_bundle = templatefile("${path.module}/data/ca.pem", {
//     PUBLIC_CRT = var.secrets_pki_ca_crt,
//     PRIVATE_KEY = var.secrets_pki_ca_key
//   })
// }
/* */

# Backends
## * googleapi: Error 400: Precondition check failed., failedPrecondition
## Above error will occur when 10 service account keys exist
resource "vault_gcp_auth_backend" "gcp" {
  credentials = var.auth_gcp
}
resource "vault_auth_backend" "cert" {
  path = "cert"
  type = "cert"
}
resource "vault_gcp_secret_backend" "gcp" {
  credentials = var.secrets_gcp
  default_lease_ttl_seconds = (24 * 3600)
  max_lease_ttl_seconds = (48 * 3600)
}
resource "vault_cert_auth_backend_role" "vault-client" {
  name = "vault-client"
  certificate = var.auth_ca_crt
  backend = vault_auth_backend.cert.path
  #allowed_common_names = ["vault-client.consul"]
  token_policies = [
    vault_policy.nomad-client.name,
    vault_policy.oinkserver-client.name,
    vault_policy.gcloud-consumer.name,
    vault_policy.tubbyland-consumer.name
  ]
}

resource "vault_pki_secret_backend_role" "vault-client" {
  backend = vault_mount.pki.path
  name = "vault-client"

  server_flag = false
  client_flag = true
  key_usage = ["NonRepudiation", "DigitalSignature", "KeyEncipherment", "DataEncipherment"]

  enforce_hostnames = true
  allow_localhost = true
  allow_bare_domains = true
  allowed_domains = [
    "vault-client.consul"
  ]

  allow_ip_sans = true
  key_bits = 2048
}
resource "vault_pki_secret_backend_role" "worker-service" {
  backend = vault_mount.pki.path
  name = "worker-service"

  server_flag = false
  client_flag = true
  key_usage = ["NonRepudiation", "DigitalSignature", "KeyEncipherment", "DataEncipherment"]

  enforce_hostnames = true
  allow_localhost = true
  allow_bare_domains = true
  allowed_domains = [
    "worker-service.consul",
    "{{identity.entity.name}}.consul"
  ]
  #"{{identity.entity.name}}.consul"
  allowed_domains_template = true

  allow_ip_sans = true
  key_bits = 2048
}
resource "vault_pki_secret_backend_cert" "leader" {
  backend = vault_mount.pki.path
  name = vault_pki_secret_backend_role.vault-client.name

  common_name = "vault-client.consul"
  alt_names = [
    "vault-client.consul"
  ]
  ip_sans = [
     "127.0.0.1",
     "169.254.1.1",
     var.secrets_pki_tls_csr.leader.public_ip,
     var.secrets_pki_tls_csr.leader.private_ip
   ]
}
resource "vault_pki_secret_backend_cert" "worker" {
  for_each = var.secrets_pki_tls_csr.worker
  backend = vault_mount.pki.path
  name = vault_pki_secret_backend_role.vault-client.name

  common_name = "vault-client.consul"
  alt_names = [
    "vault-client.consul"
  ]
  #var.secrets_pki_tls_csr.worker.public_ip[each.key],
  #var.secrets_pki_tls_csr.worker.private_ip[each.key]
  #each.value.ipv4_address,
  #each.value.ipv4_address_private
  ip_sans = [
    "127.0.0.1",
    "169.254.1.1",
    each.value.ipv4,
    each.value.ipv4-private
  ]
}
resource "vault_pki_secret_backend_cert" "worker-service" {
  for_each = var.secrets_pki_tls_csr.worker
  backend = vault_mount.pki.path
  name = vault_pki_secret_backend_role.worker-service.name

  common_name = "worker-service.consul"
  alt_names = [
    "worker-service.consul"
  ]

  ip_sans = [
    "127.0.0.1",
    "169.254.1.1",
    each.value.ipv4,
    each.value.ipv4-private
  ]
}
// resource "tls_private_key" "example" {
//   algorithm   = "ECDSA"
//   ecdsa_curve = "P256"
// }
// resource "tls_cert_request" "leader" {
//   # depends_on = [ vault_pki_secret_backend_cert.leader ]
//   // EDCSA
//   key_algorithm   = "ed25519"
//   private_key_pem = vault_pki_secret_backend_cert.leader.private_key

//   subject {
//     common_name  = "vault-client.consul"
//   }
//   dns_names = [
//     "vault-client.consul"
//   ]
//   ip_addresses = [
//     "127.0.0.1",
//     "169.254.1.1",
//     var.secrets_pki_csr.leader.public_ip,
//     var.secrets_pki_csr.leader.private_ip
//   ]
// }
// resource "vault_pki_secret_backend_sign" "leader" {
//   depends_on = [ 
//     vault_pki_secret_backend_role.vault-client,
//     vault_pki_secret_backend_cert.leader
//   ]
//   backend = vault_mount.pki.path
//   name = vault_pki_secret_backend_role.vault-client.name

//   csr = tls_cert_request.leader.csr
// }

# Could be used by Vault Clients (vault agent auto auth)
// resource "vault_gcp_auth_backend_role" "gcloud-consumer" {
//   backend = vault_auth_backend.gcp.path
//   bound_projects = [ local.project ]
//   bound_service_accounts = "*"
//   token_policies = [ "gcloud-consumer" ]
// }
# vault read auth/cert/certs/vault-client

# GCP Secret Backend Rolesets
## Depends on iam member being set
## Vault read will fail with "* googleapi: Error 400: Precondition check failed., failedPrecondition"
## when 10 account keys already exist
resource "vault_gcp_secret_roleset" "artifact-reader" {
  backend = vault_gcp_secret_backend.gcp.path
  roleset = "artifact-reader"
  secret_type = "service_account_key"
  project = "oinkserver"

  binding {
    resource = "projects/oinkserver"

    roles = [
      var.roles_gcp.artifact_reader
    ]
  }
}
resource "vault_gcp_secret_roleset" "artifact-tagger" {
  backend = vault_gcp_secret_backend.gcp.path
  roleset = "artifact-tagger"
  secret_type = "access_token"
  token_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  project = "oinkserver"

  binding {
    resource = "projects/oinkserver"

    roles = [
      var.roles_gcp.artifact_tagger,
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

# OinkCloud
resource "vault_generic_secret" "oinkserver-terraform" {
  path = "secret/oinkserver/terraform"
  data_json = jsonencode(var.terraform)
}
resource "vault_generic_secret" "oinkserver-packer" {
  path = "secret/oinkserver/packer"
  data_json = jsonencode(var.packer)
}
resource "vault_generic_secret" "oinkserver-proxy" {
  path = "secret/oinkserver/proxy"
  data_json = file("${path.module}/data/proxy.json")
}
resource "vault_generic_secret" "rtc-db" {
  path = "secret/oinkserver/rtc"
  data_json = jsonencode({
    root_password: var.nomad.rtc_db_password
  })
}
resource "vault_generic_secret" "ops-db" {
  path = "secret/oinkserver/ops"
  data_json = jsonencode({
    root_password: var.nomad.ops_db_password
  })
}

# Tubbyland
resource "vault_generic_secret" "tubbyland-oauth" {
  path = "secret/tubbyland/oauth"
  data_json = jsonencode({
    emails: var.nomad.tubbyland_oauth_emails
    internal: var.nomad.tubbyland_oauth_internal
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

