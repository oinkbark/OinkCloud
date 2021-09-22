job "tubbyland-api" {
  type = "service"
  datacenters = ["dc1"]

  constraint {
    attribute = "$${node.class}"
    value = "worker"
  }

  group "public" {
    count = 1

    network {
      mode = "host"
      port "tubbyland-graphql" {
        to = 8080
        host_network = "private"
      }
    }

    task "graphql" {
      service {
        id = "tubbyland-graphql"
        name = "tubbyland-graphql"
        port = "tubbyland-graphql"
        address_mode = "host"
      }

      env {
        GOOGLE_CLOUD_PROJECT = "tubbyland"
        CORS_ORIGIN = "https://tubbyland.com"
        // CORS_ORIGIN = "http://localhost:3000"
        NODE_ENV = "production"
        PORT = 8080
      }

      // update {
      //   # auto_revert = true
      //   auto_promote = true
      // }

      driver = "docker"

      // resources {
      //   memory = 512
      // }
  
      config {
        image = "us-docker.pkg.dev/oinkserver/tubbyland/graphql:production"
        force_pull = true

        network_mode = "bridge"
        ports = ["tubbyland-graphql"]

        // auth {
        //   server_address = "gcr.io"
        // }
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
