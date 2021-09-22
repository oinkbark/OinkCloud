# Nomad Shared Config: Agent

datacenter = "dc1"
bind_addr = "0.0.0.0"

# No ACL token is needed as a client only accepts jobs
acl {
  enabled = true
}
advertise {
  http = "{{ GetInterfaceIP `eth1` }}"
  rpc = "{{ GetInterfaceIP `eth1` }}"
  serf = "{{ GetInterfaceIP `eth1` }}"
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
