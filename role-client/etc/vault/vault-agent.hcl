vault {
  address = "https://vault.service.consul:8200"
  ca_cert = "/root/OinkServer/runtime/server.dc1.consul-ca.crt"
  client_cert = "/root/OinkServer/runtime/vault-client.consul-tls.crt"
  client_key = "/root/OinkServer/runtime/vault-client.consul-tls.key"
}

template {
  source = "/root/OinkServer/runtime/docker-env.conf.ctmpl"
  destination = "/root/OinkServer/env/docker.conf"
}

template {
  source = "/root/OinkServer/runtime/docker-auth.json.ctmpl"
  destination = "/root/OinkServer/runtime/docker-auth.json"
}

template {
  source = "/root/OinkServer/runtime/observe-writer.json.ctmpl"
  destination = "/root/OinkServer/runtime/observe-writer.json"

  # command = "systemctl start docker"
}

# export VAULT_ADDR=https://vault.service.consul:8200
# vault login -method cert -path cert -client-cert "path" -client-key "path"
# vault kv get secret/
auto_auth {
  method "cert" {
    name = "vault-client"
    ca_cert = "/root/OinkServer/runtime/server.dc1.consul-ca.crt"
    client_cert = "/root/OinkServer/runtime/vault-client.consul-tls.crt"
    client_key = "/root/OinkServer/runtime/vault-client.consul-tls.key"
  }
  // method "gcp" {
  //   config {
  //     type = "iam"
  //     role = "gcloud-consumer"
  //     credentials = "@/mnt/role_server/terraform-persist/vault-consumer.json"
  //     service_account = "vault-consumer@oinkserver.iam.gserviceaccount.com"
  //   }
  // }
}

// cache {
//   use_auto_auth_token = true
// }
