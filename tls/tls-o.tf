output "nw-us" {
  value = {
    csr = {
      leader = tls_cert_request.nw-us-leader.cert_request_pem
      worker = tls_cert_request.nw-us-worker.cert_request_pem
    }
  }
}