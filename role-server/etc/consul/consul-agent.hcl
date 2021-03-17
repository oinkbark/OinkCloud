# CLI Helper
## export CONSUL_HTTP_ADDR="169.254.1.1:8500"

datacenter = "dc1"

# Host IP
## eth1 = private VPC IP
bind_addr = "{{ GetInterfaceIP \"eth1\" }}"
# OinkServer dummy interface
## "{{ GetInterfaceIP \"oinkserver0\" }}"
client_addr = "169.254.1.1"

# Upstream DNS resolvers
recursors = ["1.1.1.1", "1.0.0.1"]

// telemetry {
//   disable_hostname = true
//   prometheus_retention_time = "30s"
//   # translate_wan_addrs = true
// }

ui_config {
  enabled = true
  // metrics_provider = "prometheus"
  // metrics_proxy {
  //   base_url = "http://metrics.service.consul:9090"
  // }
}
// encrypt = "qDOPBEr+/oUVeOFQOnVypxwDaHzLrD+lvjo5vCEBbZ0="
// ca_file = "/etc/consul.d/consul-agent-ca.pem"
// cert_file = "/etc/consul.d/dc1-server-consul-0.pem"
// key_file = "/etc/consul.d/dc1-server-consul-0-key.pem"
// verify_incoming = true
// verify_outgoing = true
// verify_server_hostname = true