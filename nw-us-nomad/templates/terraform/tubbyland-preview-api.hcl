 job "tubbyland-preview-api" {
  type = "service"
  datacenters = ["dc1"]

  group "preview" {
    count = 1

    network {
      mode = "host"
      port "tubbyland-preview-graphql" {
        to = 8000
        host_network = "private"
      }
    }

    task "preview-graphql" {
      service {
        id = "tubbyland-preview-graphql"
        name = "tubbyland-preview-graphql"
        port = "tubbyland-preview-graphql"
        address_mode = "host"
      }

      env {
        GOOGLE_CLOUD_PROJECT = "tubbyland"
        CORS_ORIGIN = "https://preview.tubbyland.com"
        NODE_ENV = "production"
        PREVIEW = true
        PORT = 8000
      }

      driver = "docker"

  
      config {
        image = "us-docker.pkg.dev/oinkserver/tubbyland/graphql:latest"
        force_pull = true

        network_mode = "bridge"
        ports = ["tubbyland-preview-graphql"]

        // command = "tail"
        // args = [
        //   "-f",
        //   "/dev/null"
        // ]

        mount {
          type = "bind"
          readonly = true
          source = "secrets/task/"
          target = "/app/secrets/live"
        }
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
${TEMPLATE_SECRET_BUCKET_MANAGER}
EOF
        destination = "secrets/task/bucket-manager.json"
      }
      template {
        data = <<EOF
${TEMPLATE_SECRET_OBJECT_ADMIN}
EOF
        destination = "secrets/task/object-admin.json"
      }
      template {
        data = <<EOF
${TEMPLATE_SECRET_OAUTH_GCP}
EOF
        destination = "secrets/task/oauth-gcp.json"
      }
      template {
        data = <<EOF
${TEMPLATE_SECRET_OAUTH_EMAILS}
EOF
        destination = "secrets/task/emails.json"
      }
      template {
        data = <<EOF
${TEMPLATE_SECRET_OAUTH_INTERNAL}
EOF
        destination = "secrets/task/internal.json"
      }
      template {
        data = <<EOF
${TEMPLATE_SECRET_DB}
EOF
        destination = "secrets/task/db.json"
      }

    }
  }
}