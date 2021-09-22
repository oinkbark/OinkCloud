job "tubbyland-ui" {
  datacenters = ["dc1"]

  constraint {
    attribute = "${node.class}"
    value = "worker"
  }

  group "web" {
    count = 1
    
    network {
      mode = "host"
      port "tubbyland-vue3" {
        to = 3000
        host_network = "private"
      }
    }

    # CORS
    # connect-src 'self' https://;
    # add_header Content-Security-Policy "default-src 'self'; connect-src 'self' https:; img-src 'self' https: data: blob:; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://cdn.jsdelivr.net https://*.google-analytics.com; font-src 'self' 'unsafe-inline' https://fonts.gstatic.com https://cdn.jsdelivr.net; style-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net https://fonts.googleapis.com; form-action 'self';  object-src 'self'" always;

    task "vue3" {
      driver = "docker"

      // resources {
      //   memory = 512
      // }

      service {
        id = "tubbyland-vue3"
        name = "tubbyland-vue3"
        port = "tubbyland-vue3"
        address_mode = "host"
      }

      env  {
        NODE_ENV = "production"
        PORT = 3000
      }

      config {
        image = "us-docker.pkg.dev/oinkserver/tubbyland/vue3:production"
        force_pull = true
        network_mode = "bridge"
        ports = ["tubbyland-vue3"]

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
