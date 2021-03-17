job "observe" {
  datacenters = ["dc1"]
  group "collector" {
    count = 1

    task "logs" {
      service {
        id = "logs"
        name = "logs"
        address_mode = "driver"
        port = 24224
      }

      driver = "docker"
      config {
        image = "fluent/fluentd:edge-debian"

        network_mode = "bridge"
        mount {
          type = "bind"
          readonly = false
          source = "/root/OinkServer/downloads/docker/"
          target = "local/downloads/"
        }
        logging {
          type = "gcplogs"
          config {
            mode = "non-blocking"
            gcp-project = "oinkserver"
          }
        }
      }
  }
}
