client {
  enabled = true
}
#https://www.nomadproject.io/docs/drivers/docker#auth-1
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
