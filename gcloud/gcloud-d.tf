// data "google_project" "oinkserver" {
//   project_id = "oinkserver"
// }
// data "google_project" "tubbyland" {
//   project_id = "tubbyland"
// }
// data "google_sourcerepo_repository" "tubbyland" {
//   name = "TubbyLand"
// }
// data "google_sourcerepo_repository" "oinkcloud" {
//   name = "OinkCloud"
// }


# Secret Versions
## These vaules are written by role-server during droplet setup
data "google_secret_manager_secret_version" "vault-root" {
  secret = "VAULT_ROOT"
}
data "google_secret_manager_secret_version" "nomad-root" {
  secret = "NOMAD_ROOT"
}
data "google_secret_manager_secret_version" "consul-ca-crt" {
  secret = "CONSUL_CA_CRT"
}

data "google_secret_manager_secret_version" "nw-us-vault-root" {
  secret = "NW-US_VAULT_ROOT"
}
data "google_secret_manager_secret_version" "nw-us-nomad-root" {
  secret = "NW-US_NOMAD_ROOT"
}
data "google_secret_manager_secret_version" "nw-us-consul-ca-crt" {
  secret = "NW-US_CONSUL_CA_CRT"
}
data "google_secret_manager_secret_version" "nw-us-consul-ca-key" {
  secret = "NW-US_CONSUL_CA_KEY"
}
# ---- IAM Policies --- #
## We are defining this data and not importing it
data "google_iam_policy" "vault-consumer" {
  binding {
    role = "roles/iam.serviceAccountTokenCreator"
    members = [ "serviceAccount:${google_service_account.vault-consumer.email}" ]
  }
}
// data "google_iam_policy" "public-bucket" {
//   binding {
//     role = "roles/storage.objectViewer"
//     members = [
//       "allUsers"
//     ]
//   }
// }