# Nomad Exclusive Config: Server
## Definition = Manages cluster, dispatches jobs to clients

data_dir = ""

consul {
  address = "169.254.1.1:8500"
}
vault {
  enabled = true
  address = "https://vault.service.consul:8200"
}
server {
  enabled = true
  # This server self elects itself as the leader
  bootstrap_expect = 1
  # Upgrade protocol for autopilot
  raft_protocol = 3
  # log_level = "INFO"

}

// tls {
//   http = true
//   rpc  = true

//   ca_file   = "server.global.nomad-ca.pem"
//   cert_file = "server.global.nomad-tls.crt"
//   key_file  = "server.global.nomad-tls.key"

//   verify_server_hostname = true
//   verify_https_client = false
// }

// # Enable autopilot (uses default values)
// autopilot {
// }


// telemetry {   
//     publish_allocation_metrics = true
//     publish_node_metrics = true

//     # statsd_address = "localhost::8125"
//     # prometheus_metrics true
// }
