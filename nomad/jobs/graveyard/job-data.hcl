job "data" {
  datacenters = ["dc1"]
  group "observability" {
    count = 1

    network {
      mode = "host"

      port "fluentd" {
        static = 24224
        to = 24224
      }
      port "prometheus" {
        static = 9090
        to = 9090
      }

      port "grafana" {
        static = 9999
        to = 9999
      }
    }

    # Collect metrics from consul services (nomad tasks)
    # todo: change name to collect
    task "metrics" {
      service {
        id = "metrics"
        name = "metrics"
        address_mode = "driver"
        //   tags = ["urlprefix-/"]
        // port = "prometheus"
      }

      driver = "docker"
      config {
        image = "prom/prometheus:latest"
        
        # needs to be able to contact consul, which current runs directly on host
        network_mode = "host"
        ports = ["prometheus"]

        mounts = [
          {
            type = "bind"
            readonly = true
            source = "local/prometheus.yml"
            target = "/etc/prometheus/prometheus.yml"
          }
        ]
      }

      template {
        change_mode = "noop"
        data = file("templates/prometheus/prom.yml")
        destination = "local/prometheus.yml"
      }
    }
    // Grafana
    # Visualize collected metrics
    task "visual" {
      service {
        id = "visual"
        name = "visual"
        address_mode = "driver"
      }

      driver = "docker"
      config {
        image = "grafana/grafana"

        network_mode = "oinkserver"
        ports = ["grafana"]

        mounts = [
          {
            type = "bind"
            readonly = true
            source = "local/grafana.ini"
            target = "/etc/grafana/grafana.ini"
          }
        ]
      }
      
      template {
        change_mode = "noop"
        data = file("templates/grafana/grafana.ini")
        destination = "local/grafana.ini"
      }

    }
    task "logs" {
      service {
        name = "logs"
        address_mode = "driver"
      }

      driver = "docker"
      config {
        image = "fluent/fluentd"

        network_mode = "oinkserver"
        ports = ["fluentd"]
      }

      #/fluentd/log
    }
  }
  // group "security" {
  //   task "vault" {

  //   }
  // }
}
