# Nomad Exclusive Config: Server
## Definition = Manages cluster, dispatches jobs to clients

data_dir = ""

server {
  enabled = true
  # How many servers are expected
  # If set to 1, this server self elects itself as the leader
  bootstrap_expect = 1
  # log_level = "INFO"

  # Upgrade protocol for autopilot
  raft_protocol = 3
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
