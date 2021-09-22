server = true
bootstrap_expect = 1
data_dir = ""

# translate_wan_addrs = true

ui_config {
  enabled = true
  // metrics_provider = "prometheus"
  // metrics_proxy {
  //   base_url = "http://metrics.service.consul:9090"
  // }
}

// telemetry {
//   disable_hostname = true
//   prometheus_retention_time = "30s"
//   # translate_wan_addrs = true
// }

// ca_file = "/etc/consul.d/consul-agent-ca.pem"
// cert_file = "/etc/consul.d/dc1-server-consul-0.pem"
// key_file = "/etc/consul.d/dc1-server-consul-0-key.pem"
// verify_incoming = true
// verify_outgoing = true
// verify_server_hostname = true

// auto_encrypt {
//   allow_tls = true
// }
