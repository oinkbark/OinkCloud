 job "tubbyland-preview" {
  type = "batch"
  datacenters = ["dc1"]

  group "testing" {
    count = 1

    task "cypress" {
      driver = "docker"

      resources {
        memory = 512
      }

      service {
        id = "tubbyland-cypress"
        name = "tubbyland-cypress"
        address_mode = "driver"
        port = 3030
      }

      config {
        image = "gcr.io/oinkserver/tubbyland-cypress:latest"
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

  group "preview" {
    count = 1

    task "preview-vue3" {
      driver = "docker"

      resources {
        memory = 256
      }

      service {
        id = "tubbyland-preview-vue3"
        name = "tubbyland-preview-vue3"
        address_mode = "driver"
        port = 3030
      }

      config {
        image = "gcr.io/oinkserver/tubbyland-vue3:${PREVIEW_COMMIT_SHA}"
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