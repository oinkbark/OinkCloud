resource "projects/oinkserver" {
  roles = [
    "roles/storage.objectAdmin",
    "roles/iam.serviceAccountTokenCreator",
  ]
}