job "proxy" {
  type = "service"
  priority = 100
  datacenters = ["dc1"]

  group "proxy" {
    count = 1

    network {
      mode = "host"

      port "http" {
        static = 80
        to = 80
      }
      port "https" {
        static = 443
        to = 443
      }
    }
    task "proxy" {
      service {
        name = "proxy"
        address_mode = "host"
      }
      restart {
        attempts = 3
        delay = "10s"
        interval = "60s"
        mode = "delay"
      }

      driver = "docker"
      config {
        image = "nginx:latest"

        network_mode = "host"
        ports = ["http", "https"]
        
        // command = "tail"
        // args = [
        //   "-f",
        //   "/dev/null"
        // ]

        # cert readonly (MIM decrypt data)
        # ip readonly (MIM direct traffic to mailicious server)

        mount {
          type = "bind"
          readonly = false
          source = "/root/OinkServer/openssl/dhparam.pem"
          target = "/etc/nginx/includes/ssl-dhparam.pem"
        }
        mount {
          type = "bind"
          readonly = false
          source = "/etc/letsencrypt/oinkserver/"
          target = "/etc/nginx/letsencrypt/"
        }
        mount {
          type = "bind"
          readonly = false
          source = "local/includes/"
          target = "/etc/nginx/includes/"
        }
        mount {
          type = "bind"
          readonly = false
          source = "local/nginx.conf"
          target = "/etc/nginx/nginx.conf"
        }
        logging {
          type = "gcplogs"
          config {
            mode = "non-blocking"
            gcp-project = "oinkserver"
          }
        }
      }

      // logging {
      //   type = "fluentd"
      //   config {
      //     fluentd-address = "fluentd.service.consul"
      //   }
      // }

      # Warning: Consul template will fail without error
      # And make the task hang in "pending" state forever
      template {
        data = <<EOF
${TEMPLATE_ORIGIN_PULL}
EOF
        destination = "local/includes/cloudflare-origin-pull.pem"
        change_mode = "noop"
      }
      template {
        data = <<EOF
${TEMPLATE_NGINX}
EOF
        destination = "local/nginx.conf"
        change_mode = "noop"
      }
      template {
        data = <<EOF
${TEMPLATE_INCLUDES} 
EOF
        destination = "local/includes/includes.conf"
        change_mode = "noop"
      }
      template {
        data = <<EOF
${TEMPLATE_SITES}
EOF
        destination = "local/includes/sites-available.conf"
        change_mode = "signal"
        change_signal = "SIGHUP"
      }

      # template
      # have certbot container write date to file after it changes a ssl cert
      # then this can watch just that file and restart the task 
      # avoids any signal sending from one task to another
    }
  }
}
