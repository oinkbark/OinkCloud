# Create child tokens for tasks
path "auth/token/create/vault-client" {
  capabilities = ["update"]
}
path "auth/token/roles/vault-client" {
  capabilities = ["read"]
}
# Validate task token permissions
path "auth/token/lookup" {
  capabilities = ["update"]
}
# Revoke dead task tokens
path "auth/token/revoke-accessor" {
  capabilities = ["update"]
}

# Validate self token on startup
path "sys/capabilities-self" {
  capabilities = ["update"]
}
path "auth/token/renew-self" {
  capabilities = ["update"]
}
