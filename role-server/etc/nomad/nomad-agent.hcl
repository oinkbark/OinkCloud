# Nomad Shared Config: Agent

datacenter = "dc1"
bind_addr = "0.0.0.0"
// # log_level = "DEBUG"

// addresses {
//   http = "{{ GetPublicIP }}"
// }
// advertise {
//   http = "{{ GetPublicIP }}"
// }
acl {
  enabled = true
}

consul {
  address = "169.254.1.1:8500"
}
vault {
  enabled = true
  address = "https://vault.service.consul:8200"
}
// tls {
//   http = true

//   ca_file = "/root/OinkServer/openssl/server.global.nomad-ca.crt"
//   key_file = "/root/OinkServer/openssl/client.global.nomad-tls.key"
//   cert_file = "/root/OinkServer/openssl/client.global.nomad-tls.crt"

//   #verify_https_client = true
//   #verify_server_hostname = true
// }

# Publish metrics for Prometheus to collect
// telemetry {
//   collection_interval = "1s"
//   disable_hostname = true
//   prometheus_metrics = true
//   publish_allocation_metrics = true
//   publish_node_metrics = true
// }

// autopilot {
//   # Uses all default values
//   # Must be here to enable
// }
