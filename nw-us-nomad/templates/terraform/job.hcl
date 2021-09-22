job "" {
  type = "service"
  datacenters = ["dc1"]

  # Jobs that use templatefile() need $ escape
  constraint {
    attribute = "$${node.class}"
    value = "worker"
  }

  group "" {
    count = 1

    network {
      mode = "host"
      port "" {
        to = 0000
        host_network = "private"
      }
    }

    task "" {
      service {
        id = ""
        name = ""
        address_mode = "host"
      }

      driver = "docker"
      config {
        image = ""

        network_mode = "bridge"
        ports = [""]

        mounts = [
          {
            type = "bind"
            readonly = true
            source = "local/"
            target = "/etc/"
          }
        ]
      }
      
      template {
        change_mode = "noop"
        data = file("templates/")
        destination = "local/"
      }

    }
  }
}
