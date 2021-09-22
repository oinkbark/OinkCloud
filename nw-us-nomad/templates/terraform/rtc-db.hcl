job "rtc-db" {
  type = "service"
  datacenters = ["dc1"]

  constraint {
    attribute = "$${node.class}"
    value = "worker"
  }

  group "persistent" {
    count = 1

    network {
      mode = "host"
      port "rtc-mysql" {
        static = 3306
        to = 3306
        host_network = "public"
      }
    }
  
    task "mysql" {
      service {
        id = "rtc-mysql"
        name = "rtc-mysql"
        port = "rtc-mysql"
        address_mode = "host"
      }

      resources {
        memory = 512
      }

      env {
        MYSQL_ROOT_PASSWORD = "${MYSQL_PASSWORD}"
      }

      driver = "docker"
      config {
        image = "mysql"
        network_mode = "bridge"
        ports = ["rtc-mysql"]
        // bind mount using --mount does not create host dir
        // bind mount using --volume does
        volumes = [
          "/root/rtc:/var/lib/mysql"
        ]
        //mount {
        //  type = "bind"
        //  source = "/root/rtc"
        //  target = "/data/db"
        //}
      }
    }
  }
}
