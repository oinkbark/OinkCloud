data_dir = "/opt/nomad"

client {
  enabled = true
  node_class = "worker"
  servers = [ "nomad.service.consul" ]

  template {
    disable_file_sandbox = false
  }

  # Networking
  network_interface = "eth1"
  cni_path = "/opt/cni/bin"
  cni_config_dir = "/opt/cni/config"
  ## Worldwide
  host_network "public" {
    interface = "eth0"
  }
  ## Private cloud
  host_network "private" {
    interface = "eth1"
  }
}
server_join {
  retry_join = [ "nomad.service.consul" ]
  retry_max = 6
  retry_interval = "10s"
}

consul {
  address = "169.254.1.1:8500"
}
vault {
  enabled = true
  address = "https://vault.service.consul:8200"

  ca_path = "/root/OinkServer/runtime/server.dc1.consul-ca.crt"
  cert_file = "/root/OinkServer/runtime/vault-client.consul-tls.crt"
  key_file = "/root/OinkServer/runtime/vault-client.consul-tls.key"
  create_from_role = "vault-client"
}

#https://www.nomadproject.io/docs/drivers/docker
plugin "docker" {
  config {
    auth {
      config = "/root/OinkServer/runtime/docker-auth.json"
    }
    volumes {
      enabled = true
    }
  }
}
