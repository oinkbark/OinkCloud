job "deb" {
  type = "service"
  datacenters = ["dc1"]
  group "linux" {
    count = 1

    task "debian" {


      driver = "docker"

  
      config {
        image = "redis:3.2"

        #network_mode = "bridge"
        mounts = [
          {
            type = "bind"
            readonly = true
            source = "secrets/task/"
            target = "/root"
          }
        ]
      }

      template {
        data = file("nomad/templates/secrets/registry-reader.json.ctmpl")
        destination = "secrets/task/registry-reader.json"
      }
    }
  }
}
