resource "google_project" "tubbyland" {
  name = "Tubbyland"
  project_id = "tubbyland"
}

# Since the tf service account is under oinkserver,m we dont enable it for tubbyland?
resource "google_project_service" "IAP-tubbyland" {
  project = google_project.tubbyland.project_id
  service = "iap.googleapis.com"
}
resource "google_project_service" "Compute-tubbyland" {
  project = google_project.tubbyland.project_id
  service = "compute.googleapis.com"
}

resource "google_project_iam_custom_role" "bucket-manager" {
  project = google_project.tubbyland.project_id
  role_id = "bucket_manager"
  title = "Bucket Manager"
  description = "Allow access to all bucket actions."
  permissions = [
    "storage.buckets.get",
    "storage.buckets.list",
    "storage.buckets.create",
    "storage.buckets.update",
    "storage.buckets.delete",
    "storage.buckets.getIamPolicy",
    "storage.buckets.setIamPolicy"
  ]
}
resource "google_project_iam_custom_role" "observe-writer" {
  project = google_project.tubbyland.project_id
  role_id = "observe_writer"
  title = "Observe Writer"
  description = "Allow access to write metrics and logs."
  permissions = [
    "logging.logEntries.create",
    "logging.buckets.write",
    "monitoring.metricDescriptors.create",
    "monitoring.metricDescriptors.get",
    "monitoring.metricDescriptors.list",
    "monitoring.timeSeries.create"
  ]
  # "monitoring.monitoredResourceDescriptors.get",
  # "monitoring.monitoredResourceDescriptors.list",
}
resource "google_project_iam_custom_role" "tubbyland-key-generator" {
  project = google_project.tubbyland.project_id
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
resource "google_project_iam_member" "tubbyland-vault-generator" {
  project = google_project.tubbyland.project_id
  member = "serviceAccount:${google_service_account.vault-generator.email}"
  role = google_project_iam_custom_role.tubbyland-key-generator.name
}
resource "google_project_iam_member" "tubbyland-observe-writer" {
  project = google_project.tubbyland.project_id
  member = "serviceAccount:${var.oinkserver_observe_account}"
  role = google_project_iam_custom_role.observe-writer.name
}
# Website Assets
resource "google_storage_bucket" "tubbyland" {
  project = google_project.tubbyland.project_id
  name = "tubbyland.com"
  uniform_bucket_level_access = true

  versioning {
    enabled = false
  }
}
resource "google_storage_bucket_iam_member" "public" {
  bucket = google_storage_bucket.tubbyland.name
  role = "roles/storage.objectViewer"
  member = "allUsers"
}

# Load Balancer and Cache
## Backend Configuration
resource "google_compute_backend_bucket" "tubbyland" {
  project = google_project.tubbyland.project_id
  provider = google-beta
  name = "tubbyland"
  bucket_name = google_storage_bucket.tubbyland.name
  enable_cdn = true

  cdn_policy {
    cache_mode = "CACHE_ALL_STATIC"
    default_ttl = (8 * 3600)
    client_ttl = (24 * 3600)
    max_ttl = (48 * 3600)
  }
}
## Host and path rules
resource "google_compute_url_map" "tubbyland" {
  provider = google-beta
  project = google_project.tubbyland.project_id
  name = "tubbyland"
  default_service = google_compute_backend_bucket.tubbyland.id
}
## Frontend configuration
resource "google_compute_target_http_proxy" "tubbyland" {
  provider = google-beta
  project = google_project.tubbyland.project_id
  name = "tubbyland"
  url_map = google_compute_url_map.tubbyland.id
}
## Very expensive
// resource "google_compute_global_address" "tubbyland" {
//   provider = google-beta
//   project = google_project.tubbyland.project_id
//   name = "tubbyland"
//   address_type = "EXTERNAL"
//   ip_version = "IPV4"
// }
// resource "google_compute_global_forwarding_rule" "tubbyland" {
//   provider = google-beta
//   project = google_project.tubbyland.project_id
//   name = "public"
//   target = google_compute_target_http_proxy.tubbyland.id
//   port_range = "80-80"
//   ip_protocol = "TCP"
//   load_balancing_scheme = "EXTERNAL"
//   #ip_version = "IPV4"
//   ip_address = google_compute_global_address.tubbyland.address
// }

# Logging
resource "google_logging_project_bucket_config" "tubbyland" {
    project = google_project.tubbyland.project_id
    location  = "global"
    retention_days = 30
    bucket_id = "docker"
}
resource "google_logging_project_sink" "docker" {
  project = google_project.tubbyland.project_id
  name = "Docker"

  destination = "logging.googleapis.com/${google_logging_project_bucket_config.tubbyland.id}"
  filter = "logName=\"projects/tubbyland/logs/gcplogs-docker-driver\""
  unique_writer_identity = true
}




#tf import module.gcloud.google_iap_brand.tubbyland projects/{{ project number }}/brands/tubbyland
#tf import module.gcloud.google_iap_client.tubbyland projects/{{ project number }}/brands/tubbyland/identityAwareProxyClients/{{ client id }}

# OAuth 2.0 Client
## Bug: Error: Error creating Brand: googleapi: Error 400: Request contains an invalid argument.
// resource "google_iap_brand" "tubbyland" {
//   support_email = "oinkbark@gmail.com"
//   application_title = "Tubbyland"
//   project = google_project.tubbyland.project_id
// }
// resource "google_iap_client" "tubbyland" {
//   display_name = "Tubbyland"
//   brand = google_iap_brand.tubbyland.name
// }