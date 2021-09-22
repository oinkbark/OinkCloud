job "proxy" {
  type = "service"
  priority = 100
  datacenters = ["dc1"]

  # Job Management Strategies
  constraint {
    attribute = "$${node.class}"
    value = "leader"
  }
  reschedule {
    unlimited = true
    delay = "5s"
    delay_function = "constant"
  }
  ## Must force update (no canary); otherwise port is exhausted
  update {
    max_parallel = 0
    min_healthy_time = "10s"
    healthy_deadline = "1m"
  }

  group "proxy" {
    count = 1

    network {
      mode = "host"

      port "http" {
        static = 80
        to = 80
        host_network = "public"
      }
      port "https" {
        static = 443
        to = 443
        host_network = "public"
      }
      # Nomad is not opening this through nftables/docker automatically
      port "neo4j" {
        static = 7687
        to = 7687
        host_network = "public"
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
        ports = ["http", "https", "neo4j"]
        dns_servers = ["169.254.1.1"]

        mount {
          type = "bind"
          readonly = false
          source = "/root/OinkServer/openssl/dhparam.pem"
          target = "/etc/nginx/includes/certs/ssl-dhparam.pem"
        }
        mount {
          type = "bind"
          readonly = false
          source = "${TEMPLATE_CERT_MOUNT}/oinkserver/"
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

      template {
        data = <<EOF
${TEMPLATE_ORIGIN_PULL}
EOF
        destination = "local/includes/certs/cloudflare-origin-pull.pem"
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
${TEMPLATE_HTTP}
EOF
        destination = "local/includes/sites-available.conf"
        change_mode = "signal"
        change_signal = "SIGHUP"
      }
      template {
        data = <<EOF
${TEMPLATE_STREAM}
EOF
        destination = "local/includes/stream.conf"
        change_mode = "signal"
        change_signal = "SIGHUP"
      }
      # Trigger NGINX reload to accept new certificates after renewal
      ## Requires file sandbox to be disabled
      ## Can use file function inside template as well
      template {
        source = "${TEMPLATE_CERT_MOUNT}/last-renew"
        destination = "local/last-renew"
        change_mode = "signal"
        change_signal = "SIGHUP"
      }
      template {
        data = <<EOF
${TEMPLATE_CA_BUNDLE}
EOF
        destination = "local/includes/certs/ca-bundle.pem"
      }
    }
  }
}
