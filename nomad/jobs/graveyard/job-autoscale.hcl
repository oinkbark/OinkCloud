job "autoscaler" {
  datacenters = ["dc1"]

  group "autoscaler" {
    count = 1

    task "autoscaler" {
      driver = "docker"

      config {
        image   = "hashicorp/nomad-autoscaler:latest"
        command = "nomad-autoscaler"

        args = [
          "agent",
          "-config",
          "nomad-autoscale.hcl",
          "-http-bind-address",
          "0.0.0.0",
        ]

        port_map {
          http = 8080
        }
      }
    }
  }
}


# https://www.hashicorp.com/blog/hashicorp-nomad-autoscaling-tech-preview
    // scaling {
    //   enabled = true
    //   min = 1
    //   max = 3

    //   policy {
    //     evaluation_interval = "5s"
    //     cooldown            = "1m"

    //     check "active_connections" {
    //       source = "prometheus"
    //       query  = "scalar(open_connections_example_cache)"

    //       strategy "target_value" {
    //         target = 10
    //       }
    //     }
    //   }
  
    // }
    