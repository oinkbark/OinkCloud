output "tubbyland-db" {
  value = random_password.tubbyland-db.result
}
output "tubbyland-internal" {
  value = [ random_id.tubbyland-internal.id ]
}