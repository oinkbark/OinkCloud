resource "random_password" "tubbyland-db" {
  length = 44
}
resource "random_id" "tubbyland-internal" {
  byte_length = 16
}