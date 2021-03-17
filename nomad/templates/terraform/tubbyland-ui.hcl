// https://www.nomadproject.io/docs/job-specification/hcl2

// variable "docker_images" {
//   default = {
//     "oink-nuxt": "gcr.io/oinkbark/oink-nuxt:latest"
//     "certbot": "certbot/dns-cloudflare"
//   }
// }

# Consul = how containers talk to one another, including if they are on different hosts
# ports = how containers accept conntections

# Ingress gateway - look into
# https://www.hashicorp.com/blog/introducing-hashicorp-nomad-v0-12-s-new-consul-ingress-gateway-capability

job "tubbyland-ui" {
  datacenters = ["dc1"]

  group "web" {
    count = 1

    # CORS
    # connect-src 'self' https://;
    # add_header Content-Security-Policy "default-src 'self'; connect-src 'self' https:; img-src 'self' https: data: blob:; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://cdn.jsdelivr.net https://*.google-analytics.com; font-src 'self' 'unsafe-inline' https://fonts.gstatic.com https://cdn.jsdelivr.net; style-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net https://fonts.googleapis.com; form-action 'self';  object-src 'self'" always;

    task "vue3" {
      driver = "docker"

      resources {
        memory = 512
      }

      service {
        id = "tubbyland-vue3"
        name = "tubbyland-vue3"
        address_mode = "driver"
        port = 3000
      }

      env  {
        NODE_ENV = "production"
      }

      config {
        image = "gcr.io/oinkserver/tubbyland-vue3:${PROD_COMMIT_SHA}"
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

  