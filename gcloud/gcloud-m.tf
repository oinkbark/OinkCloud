# Verify domain (for buckets)
# Must add terraform service account as a domain owner
# https://search.google.com/search-console/
# https://www.google.com/webmasters/verification/home#

# OAuth 2.0 Client must be created manuallyt, then imported
# https://cloud.google.com/sdk/gcloud/reference


# API Services
## You may have to wait some time for the change to propagate
## Some require billing to be setup (yoiu cannot be at your quota limit)
resource "google_project_service" "Resources" {
  service = "cloudresourcemanager.googleapis.com"
}
resource "google_project_service" "Services" {
  service = "serviceusage.googleapis.com"
}
resource "google_project_service" "IAM" {
  service = "iam.googleapis.com"
}
resource "google_project_service" "KMS" {
  service = "cloudkms.googleapis.com"
}
resource "google_project_service" "Secrets" {
  service = "secretmanager.googleapis.com"
}
// resource "google_project_service" "PubSub" {
//   service = "pubsub.googleapis.com"
// }
# Automatically enables pub/sub (for build triggers)
resource "google_project_service" "Cloud-Build" {
  service = "cloudbuild.googleapis.com"
}
resource "google_project_service" "Repo" {
  service = "sourcerepo.googleapis.com"
}
resource "google_project_service" "Storage" {
  service = "storage.googleapis.com"
}
resource "google_project_service" "Compute" {
  service = "compute.googleapis.com"
}
# probably just use an input variable?
// resource "google_project_service" "Site-Verify-tubbyland" {
//   project = google_project.tubbyland.project_id
//   service = "siteverification.googleapis.com"
// }

# Projects
## Must manually add terraform service account as an owner through IAM members
resource "google_project" "oinkserver" {
  name = "OinkServer"
  project_id = "oinkserver"
}

# Artifact Registry
resource "google_artifact_registry_repository" "tubbyland" {
  provider = google-beta
  project = "oinkserver"

  location = "us"
  repository_id = "tubbyland"
  format = "DOCKER"
}

# Custom Roles
## https://cloud.google.com/iam/docs/understanding-roles
## https://cloud.google.com/iam/docs/custom-roles-permissions-support
## Used by Vault externally
resource "google_project_iam_custom_role" "secret-writer" {
  role_id = "secret_writer"
  title = "Secret Writer"
  description = "Allow secret versions to be written."
  permissions = [
    "secretmanager.versions.add"
  ]
}
resource "google_project_iam_custom_role" "key-verifier" {
  role_id = "key_verifier"
  title = "Key Verifier"
  description = "Allow view access to all service account keys."
  permissions = [
    "iam.serviceAccounts.get",
    "iam.serviceAccountKeys.get",
  ]
}
resource "google_project_iam_custom_role" "key-generator" {
  role_id = "key_generator"
  title = "Key Generator"
  description = "Allow admin access to all service account & key operations."
  permissions = [
  "iam.serviceAccounts.create",
  "iam.serviceAccounts.delete",
  "iam.serviceAccounts.get",
  "iam.serviceAccounts.list",
  "iam.serviceAccounts.update",
  "iam.serviceAccountKeys.create",
  "iam.serviceAccountKeys.delete",
  "iam.serviceAccountKeys.get",
  "iam.serviceAccountKeys.list",
  "resourcemanager.projects.getIamPolicy",
  "resourcemanager.projects.setIamPolicy"
  ]
}
resource "google_project_iam_custom_role" "cloud-build-sa" {
  role_id = "cloud_build_sa"
  title = "Cloud Build SA"
  description = "Allow cloud build to access project resources."
  permissions = [
    "secretmanager.versions.access",
    "artifactregistry.repositories.uploadArtifacts",
  ]
}
resource "google_project_iam_custom_role" "artifact-tagger" {
  role_id = "artifact_tagger"
  title = "Artifact Tagger"
  description = "Allow access to modify artifact tags."
  permissions = [
    "artifactregistry.tags.get",
    "artifactregistry.tags.list",
    "artifactregistry.tags.create",
    "artifactregistry.tags.update",
    "artifactregistry.tags.delete"
  ]
}
resource "google_project_iam_custom_role" "artifact-reader" {
  role_id = "artifact_reader"
  title = "Artifact Reader"
  description = "Allow access to fetch artifacts."
  permissions = [
    "artifactregistry.files.get",
    "artifactregistry.packages.get",
    "artifactregistry.repositories.downloadArtifacts"
  ]
}

# Service Accounts
## System
resource "google_service_account" "secret-writer" {
  account_id = "secret-writer"
}
## Hashicorp Vault
resource "google_service_account" "vault-unseal" {
  account_id = "vault-unseal"
}
resource "google_service_account" "vault-generator" {
  account_id = "vault-generator"
}
resource "google_service_account" "vault-verifier" {
  account_id = "vault-verifier"
}
resource "google_service_account" "vault-consumer" {
  account_id = "vault-consumer"
}

# Service Account Keys
## Must be created at same time as server droplet for private key access
## Need to find good way to rotate these
resource "google_service_account_key" "vault-unseal" {
  service_account_id = google_service_account.vault-unseal.name
}
resource "google_service_account_key" "secret-writer" {
  service_account_id = google_service_account.secret-writer.name
}
resource "google_service_account_key" "vault-generator" {
  service_account_id = google_service_account.vault-generator.name
}
resource "google_service_account_key" "vault-verifier" {
  service_account_id = google_service_account.vault-verifier.name
}
# Would be used by Vault Clients (vault agent auto auth)
// resource "google_service_account_key" "vault-consumer" {
//   service_account_id = google_service_account.vault-consumer.name
// }

# Project Member IAM Policies
## We cannot use one singular authoritative policy for a project or role;
## Otherwise, Vault cannot externally create the role permissions it needs to
resource "google_project_iam_member" "secret-writer" {
  member = "serviceAccount:${google_service_account.secret-writer.email}"
  role = google_project_iam_custom_role.secret-writer.name
}
## - Vault (Exists on role-server) -
resource "google_project_iam_member" "vault-unseal" {
  member = "serviceAccount:${google_service_account.vault-unseal.email}"
  role = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
}
## - Vault -
resource "google_project_iam_member" "vault-generator" {
  member = "serviceAccount:${google_service_account.vault-generator.email}"
  role = google_project_iam_custom_role.key-generator.name
}
resource "google_project_iam_member" "vault-verifier" {
  member = "serviceAccount:${google_service_account.vault-verifier.email}"
  role = google_project_iam_custom_role.key-verifier.name
}
## - Cloud Build -
resource "google_project_iam_member" "cloud-build" {
  # member = "serviceAccount:${google_project_service_identity.cloud-build.email"
  member = "serviceAccount:${google_project.oinkserver.number}@cloudbuild.gserviceaccount.com"
  role = google_project_iam_custom_role.cloud-build-sa.name
}
resource "google_project_iam_member" "cloud-build-artifact-tagger" {
  # member = "serviceAccount:${google_project_service_identity.cloud-build.email"
  member = "serviceAccount:${google_project.oinkserver.number}@cloudbuild.gserviceaccount.com"
  role = google_project_iam_custom_role.artifact-tagger.name
}
// resource "google_project_service_identity" "cloud-build" {
//   service = "cloudbuild.googleapis.com"
// }


# Service Account IAM Policies
## Only allow consumer to generate tokens for their own account
## Not for all service accounts in the project
resource "google_service_account_iam_policy" "vault-consumer" {
  service_account_id = google_service_account.vault-consumer.name
  policy_data        = data.google_iam_policy.vault-consumer.policy_data
}

# Vault Seal
resource "google_kms_key_ring" "vault-keyring" {
  name = "vault-keyring"
  location = "global"
}
resource "google_kms_crypto_key" "crypto_key" {
  name = "vault-key"
  key_ring = google_kms_key_ring.vault-keyring.self_link
  #rotation_period = "100000s"
}

// # Add the service account to the Keyring
// resource "google_kms_key_ring_iam_binding" "vault_iam_kms_binding" {
//   key_ring_id = "${google_kms_key_ring.vault-keyring.id}"
//   #role = "roles/owner"

//   members = [
//     "serviceAccount:${google_service_account.vault-unseal.email}",
//   ]
// }

# Application Runtime Secrets
resource "google_secret_manager_secret" "digitalocean-token" {
  secret_id = "DIGITALOCEAN_TOKEN"

  replication {
    automatic = true
  }
}
resource "google_secret_manager_secret" "ssh-public-keys" {
  secret_id = "SSH_PUBLIC_KEYS"

  replication {
    automatic = true
  }
}
# On role-server machine
resource "google_secret_manager_secret" "vault-unseal" {
  secret_id = "VAULT_UNSEAL_JSON"

  replication {
    automatic = true
  }
}
resource "google_secret_manager_secret" "secret-writer" {
  secret_id = "SECRET_WRITER_JSON"

  replication {
    automatic = true
  }
}
# Used in resource definition
resource "google_secret_manager_secret" "vault-generator" {
  secret_id = "VAULT_GENERATOR_JSON"

  replication {
    automatic = true
  }
}
resource "google_secret_manager_secret" "vault-verifier" {
  secret_id = "VAULT_VERIFIER_JSON"

  replication {
    automatic = true
  }
}
# Values filled by machine at runtime (each are region specific)
## These MUST exist before a role-server image can fill them
resource "google_secret_manager_secret" "vault-root" {
  secret_id = "VAULT_ROOT"

  replication {
    automatic = true
  }
}
resource "google_secret_manager_secret" "nomad-root" {
  secret_id = "NOMAD_ROOT"

  replication {
    automatic = true
  }
}
resource "google_secret_manager_secret" "consul-ca-crt" {
  secret_id = "CONSUL_CA_CRT"

  replication {
    automatic = true
  }
}
resource "google_secret_manager_secret" "nw-us-vault-root" {
  secret_id = "NW-US_VAULT_ROOT"

  replication {
    automatic = true
  }
}
resource "google_secret_manager_secret" "nw-us-nomad-root" {
  secret_id = "NW-US_NOMAD_ROOT"

  replication {
    automatic = true
  }
}
resource "google_secret_manager_secret" "nw-us-consul-ca-crt" {
  secret_id = "NW-US_CONSUL_CA_CRT"

  replication {
    automatic = true
  }
}
resource "google_secret_manager_secret" "nw-us-consul-ca-key" {
  secret_id = "NW-US_CONSUL_CA_KEY"

  replication {
    automatic = true
  }
}

  # key = google_service_account_key.vault-unseal.private_key,
  // secret_data = templatefile("${path.module}/credentials.tmpl", {
  //   key = "oof"
  //   key-id = google_service_account_key.vault-unseal.public_key,
  //   client-email = google_service_account.vault-unseal.email,
  //   client-id = google_service_account.vault-unseal.unique_id
  // })
# Packer Build Time
resource "google_secret_manager_secret_version" "digitalocean-token" {
  secret = google_secret_manager_secret.digitalocean-token.id
  secret_data = var.digitalocean_token
}
resource "google_secret_manager_secret_version" "ssh-public-keys" {
  secret = google_secret_manager_secret.ssh-public-keys.id
  secret_data = var.ssh_public_keys
}
# Runtime
resource "google_secret_manager_secret_version" "secret-writer" {
  secret = google_secret_manager_secret.secret-writer.id
  secret_data = base64decode(google_service_account_key.secret-writer.private_key)
}
resource "google_secret_manager_secret_version" "vault-unseal" {
  secret = google_secret_manager_secret.vault-unseal.id
  secret_data = base64decode(google_service_account_key.vault-unseal.private_key)
}
# Terraform resource
resource "google_secret_manager_secret_version" "vault-generator" {
  secret = google_secret_manager_secret.vault-generator.id
  secret_data = base64decode(google_service_account_key.vault-generator.private_key)
}
resource "google_secret_manager_secret_version" "vault-verifier" {
  secret = google_secret_manager_secret.vault-verifier.id
  secret_data = base64decode(google_service_account_key.vault-verifier.private_key)
}

resource "google_storage_bucket" "build-manifests" {
  name = "build-manifests.buckets.${var.oinkserver_domain_link}"
  uniform_bucket_level_access = true

  versioning {
    enabled = false
  }
}

# Set env PACKER_GITHUB_API_TOKEN (limit of 1 pull per hour for plugins)
resource "google_cloudbuild_trigger" "machine-img-build-chain" {
  for_each = var.machine-img-downstream

  name = each.key

  trigger_template {
    branch_name = each.key
    repo_name = "OinkCloud"
  }

  # Can use this instead of build block
  # filename = "${each.key}/${each.key}.gcloud.yml"

  build {
    # 10 min for self, plus 8 minutes per child
    timeout = "${600 + (length(each.value) * (60 * 8))}s"

    source {
      repo_source {
        project_id = google_project.oinkserver.id
        repo_name = "OinkCloud"
        branch_name = each.key
        dir = each.key
      }
    }

    # Inject External Image ID
    dynamic "step" {
      for_each = each.value.parent
      content {
        name = "gcr.io/cloud-builders/gsutil"
        args = [
          "cp", 
          "${google_storage_bucket.build-manifests.url}/${step.value}.manifest.json",
          "/workspace/external-manifest.json"
        ]
      }
    }
    # Inject Secrets
    step {
      name = "gcr.io/cloud-builders/gcloud"
      entrypoint = "bash"
      args = [
        "-c",
        "gcloud secrets versions access latest --secret=DIGITALOCEAN_TOKEN --format='get(payload.data)' | base64 -d > /workspace/digitalocean_token.txt"
      ]
    }
    step {
      name = "gcr.io/cloud-builders/gcloud"
      entrypoint = "bash"
      args = [
        "-c",
        "gcloud secrets versions access latest --project=oinkserver --secret=SSH_PUBLIC_KEYS --format='get(payload.data)' | base64 -d > /workspace/ssh_public_keys.txt"
      ]
    }
    step {
      name = "gcr.io/cloud-builders/gcloud"
      entrypoint = "bash"
      args = [
        "-c",
        "echo Using image ID: $(sed -n 's/.*\"artifact_id\": \".*:\\(.*\\)\".*/\\1/p' /workspace/external-manifest.json 2>/dev/null || echo debian-10-x64)"
      ]
    }

    # Initalize Packer builder sources
    step {
      name = "hashicorp/packer:light"
      dir = "/workspace/${each.key}"
      entrypoint = "bash"
      args = [
        "-c",
        "packer init ${each.key}.pkr.hcl"
      ]
    }
    # Build parent
    # grep -oP "artifact_id": ".*:(.*)" | cut -d ":" -f2
    # sed -n 's/.*"artifact_id": ".*:\(.*\)".*/\1/p'
    step {
      id = "parent"
      name = "hashicorp/packer:light"
      dir = "/workspace/${each.key}"
      entrypoint = "bash"
      args = [
        "-c",
        "packer build -var digitalocean_token=$(cat /workspace/digitalocean_token.txt) -var parent_image_id=$(sed -n 's/.*\"artifact_id\": \".*:\\(.*\\)\".*/\\1/p' /workspace/external-manifest.json 2>/dev/null || echo debian-10-x64) ${each.key}.pkr.hcl"
      ]
    }
    # Save parent build manifest to bucket
    step {
      id = "parent-manifest"
      name = "gcr.io/cloud-builders/gsutil"
      args = [
        "cp", 
        "/workspace/manifest.json",
        "${google_storage_bucket.build-manifests.url}/${each.key}.manifest.json"
      ]
    }

    # Build Child Images
    # Couldn't read commit refs/heads/base-exec if branch does not exist
    dynamic "step" {
      for_each = each.value.children
      content {
        wait_for = [ "parent-manifest" ]
        name = "gcr.io/cloud-builders/gcloud"
        entrypoint = "bash"
        args = [
          "-c",
          "gcloud alpha builds triggers run --branch=${step.value} ${step.value} || exit 0"
        ]
      }
    }
  }
}
# Cannot have just one step
## Otherwise, it defaults to Dockerfile build config
## Which cannot have custom Dockerfile names
resource "google_cloudbuild_trigger" "tubbyland-docker" {
  for_each = var.tubbyland-docker

  name = each.key

  trigger_template {
    branch_name = each.key
    repo_name = "TubbyLand"
  }
  build {

    source {
      repo_source {
        project_id = google_project.oinkserver.id
        repo_name = "TubbyLand"
        branch_name = each.key
        dir = each.key
      }
    }

    step {
      name = "gcr.io/cloud-builders/docker"
      dir = "/workspace/tubbyland-${each.key}"
      entrypoint = "bash"
      args = [
        "-c",
        "echo $(docker -v)"
      ]
    }
    step {
      name = "gcr.io/cloud-builders/docker"
      dir = "/workspace/tubbyland-${each.key}"
      entrypoint = "bash"
      args = [
        "-c",
        "docker build --build-arg SHORT_SHA=$SHORT_SHA -t us-docker.pkg.dev/oinkserver/tubbyland/${each.key}:$SHORT_SHA -f prod.Dockerfile ."
      ]
    }
    step {
      name = "gcr.io/cloud-builders/docker"
      dir = "/workspace/tubbyland-${each.key}"
      entrypoint = "bash"
      args = [
        "-c",
        "docker tag us-docker.pkg.dev/oinkserver/tubbyland/${each.key}:$SHORT_SHA us-docker.pkg.dev/oinkserver/tubbyland/${each.key}:latest"
      ]
    }
    artifacts {
      images = [ 
        "us-docker.pkg.dev/oinkserver/tubbyland/${each.key}:$SHORT_SHA",
        "us-docker.pkg.dev/oinkserver/tubbyland/${each.key}:latest"
      ]
    }
  }
}
