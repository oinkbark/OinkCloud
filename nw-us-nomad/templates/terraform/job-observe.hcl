job "observe" {
  datacenters = ["dc1"]

  constraint {
    attribute = "${node.class}"
    operator = "is_set"
  }

  group "collector" {
    count = 1

    network {
      mode = "host"
      port "logs" {
        to = 24224
        host_network = "private"
      }
    }

    task "logs" {
      service {
        id = "logs"
        name = "logs"
        port = "logs"
        address_mode = "host"
      }

      driver = "docker"
      config {
        image = "fluent/fluentd:edge-debian"

        network_mode = "bridge"
        ports = ["logs"]

        mount {
          type = "bind"
          readonly = true
          source = "local/"
          target = "/fluentd/etc/"
        }
        # fluent must be able to create pos files
        mount {
          type = "bind"
          readonly = true
          source = "/var/log/oinkserver/"
          target = "/fluentd/log/oinkserver/"
        }
        logging {
          type = "gcplogs"
          config {
            mode = "non-blocking"
            gcp-project = "oinkserver"
          }
        }
      }

      template {
        data = <<EOF
${TEMPLATE_FLUENT}
EOF
        destination = "local/fluent.conf"
        change_mode = "noop"
      }
    }

    // network {
    //   mode = "host"

    //   port "fluentd" {
    //     static = 24224
    //     to = 24224
    //   }
    //   port "prometheus" {
    //     static = 9090
    //     to = 9090
    //   }

    //   port "grafana" {
    //     static = 9999
    //     to = 9999
    //   }
    // }

    # Collect metrics from consul services (nomad tasks)
    # todo: change name to collect
    // task "metrics" {
    //   service {
    //     id = "metrics"
    //     name = "metrics"
    //     address_mode = "driver"
    //     port = 9090
    //   }

    //   driver = "docker"
    //   config {
    //     image = "prom/prometheus:latest"
        
    //     # needs to be able to contact consul, which current runs directly on host
    //     network_mode = "host"
    //     ports = ["prometheus"]

    //     mounts = [
    //       {
    //         type = "bind"
    //         readonly = true
    //         source = "local/prometheus.yml"
    //         target = "/etc/prometheus/prometheus.yml"
    //       }
    //     ]
    //   }

    //   template {
    //     change_mode = "noop"
    //     data = file("templates/prometheus/prom.yml")
    //     destination = "local/prometheus.yml"
    //   }
    // }
    # Visualize collected metrics
    // task "grafana" {
    //   service {
    //     id = "visual"
    //     name = "visual"
    //     address_mode = "driver"
    //   }

    //   driver = "docker"
    //   config {
    //     image = "grafana/grafana"
    //     network_mode = "brdige"

    //     mount {
    //       type = "bind"
    //       readonly = true
    //       source = "local/grafana.ini"
    //       target = "/etc/grafana/grafana.ini"
    //     }
    //   }
      
    //   template {
    //     change_mode = "noop"
    //     data = file("templates/grafana/grafana.ini")
    //     destination = "local/grafana.ini"
    //   }

    // }
  }
}
