job "" {
  type = "service"
  datacenters = ["dc1"]
  group "" {
    count = 1

    task "" {
      service {
        id = ""
        name = ""
        address_mode = "driver"
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
