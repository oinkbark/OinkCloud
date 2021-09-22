 job "tubbyland-preview-ui" {
  type = "service"
  datacenters = ["dc1"]

  group "preview" {
    count = 1

    task "preview-vue3" {
      driver = "docker"

      resources {
        memory = 512
      }

      service {
        id = "tubbyland-preview-vue3"
        name = "tubbyland-preview-vue3"
        address_mode = "driver"
        port = 3030
      }

      env  {
        NODE_ENV = "production"
        PREVIEW = true
        PORT = 3030
      }

      config {
        image = "us-docker.pkg.dev/oinkserver/tubbyland/vue3:latest"
        force_pull = true
        network_mode = "bridge"

        logging {
          type = "gcplogs"
          config {
            mode = "non-blocking"
            gcp-project = "tubbyland"
          }
        }
      }
    }
  }
}