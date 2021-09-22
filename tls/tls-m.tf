resource "tls_cert_request" "nw-us-leader" {
  // EDCSA
  key_algorithm   = "ed25519"
  private_key_pem = var.nw-us.leader.private_key

  subject {
    common_name  = "vault-client.consul"
  }
  dns_names = [
    "vault-client.consul"
  ]
  ip_addresses = [
    "127.0.0.1",
    "169.254.1.1",
    var.nw-us.leader.public_ip,
    var.nw-us.leader.private_ip
  ]
}

resource "tls_cert_request" "nw-us-worker" {
  // EDCSA
  key_algorithm   = "ed25519"
  private_key_pem = var.nw-us.worker.private_key

  subject {
    common_name  = "vault-client.consul"
  }
  dns_names = [
    "vault-client.consul"
  ]
  ip_addresses = [
    "127.0.0.1",
    "169.254.1.1",
    var.nw-us.worker.public_ip,
    var.nw-us.worker.private_ip
  ]
}
