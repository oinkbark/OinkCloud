job "deb" {
  type = "service"
  datacenters = ["dc1"]
  group "linux" {
    count = 1

    task "debian" {
      driver = "docker"
      network_mode = "bridge"
      config {
        image = "debian:buster"
        command = "tail"
        args = [ "/dev/null" ]
      }
    }
  }
}
