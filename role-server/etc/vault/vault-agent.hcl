vault {
  address = "https://169.254.1.1:8200"
  ca_cert = "/root/OinkServer/openssl/server.dc1.consul-ca.crt"
  client_cert = "/root/OinkServer/openssl/agent.consul-tls.crt"
  client_key = "/root/OinkServer/openssl/agent.consul-tls.key"
}

template {
  source = "/root/OinkServer/runtime/observe-writer.json.ctmpl"
  destination = "/root/OinkServer/runtime/observe-writer.json"
}

template {
  source = "/root/OinkServer/runtime/docker-auth.json.ctmpl"
  destination = "/root/OinkServer/runtime/docker-auth.json"
}

template {
  source = "/root/OinkServer/runtime/docker-env.conf.ctmpl"
  destination = "/root/OinkServer/env/docker.conf"
}

auto_auth {
  method "cert" {
    name = "vault-client"
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
