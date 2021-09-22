 job "tubbyland-preview-tests" {
  type = "batch"
  datacenters = ["dc1"]

  group "tests" {
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
        port = 3333
      }

      config {
        image = "us-docker.pkg.dev/oinkserver/tubbyland/cypress:latest"
        network_mode = "bridge"

        logging {
          type = "gcplogs"
          config {
            mode = "non-blocking"
            gcp-project = "tubbyland"
          }
        }
      }
      template {
        data = <<EOF
${TEMPLATE_SECRET_OAUTH_INTERNAL}
EOF
        destination = "secrets/task/internal.json"
      }
    }
  }
}