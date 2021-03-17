job "tubbyland-db" {
  type = "service"
  datacenters = ["dc1"]
  group "persistent" {
    count = 1
  
    task "mongo" {
      service {
        id = "tubbyland-mongo"
        name = "tubbyland-mongo"
        address_mode = "driver"
        port = 27017
      }

      env {
        MONGO_INITDB_ROOT_USERNAME = "${MONGO_USERNAME}"
        MONGO_INITDB_ROOT_PASSWORD = "${MONGO_PASSWORD}"
        MONGO_INITDB_DATABASE = "OinkServer"
      }

      driver = "docker"
      config {
        image = "mongo:bionic"
        network_mode = "bridge"
        // bind mount using --mount does not create host dir
        // bind mount using --volume does
        volumes = [
          "/mnt/tubbyland/mongo:/data/db"
        ]
        //mount {
        //  type = "bind"
        //  source = "/mnt/tubbyland/mongo"
        //  target = "/data/db"
        //}
      }
      
      // {
      //   type = "bind"
      //   readonly = true
      //   source = "local/mongod.conf"
      //   target = "/etc/mongod.conf"
      // },
      // template {
      //   change_mode = "noop"
      //   data = file("templates/mongo/mongod.conf")
      //   destination = "local/"
      // }
    }

  }
  group "cache" {
    count = 1

    task "redis" {
      service {
        id = "tubbyland-redis"
        name = "tubbyland-redis"
        address_mode = "driver"
        port = 6379
      }

      driver = "docker"
      config {
        image = "redis"
        args = [ "/etc/redis/redis.conf" ]

        network_mode = "bridge"

        // Only certain namespaces are supported (vm is not)
        sysctl = {
          "net.core.somaxconn" = "512"
        }

        mount {
          type = "bind"
          readonly = true
          source = "local/redis.conf"
          target = "/etc/redis/redis.conf"
        }
        logging {
          type = "gcplogs"
          config {
            mode = "non-blocking"
            gcp-project = "tubbyland"
          }
        }
      }

      // healthcheck once per x minutes
      // sends request to api to fetch project
      // if cache size is 0, then call fillCache() command
      // avoids live user being hit with a cold start from cache
      // also avoids needing to link redis to mongo directly through nomad (api does it instead)

      template {
        change_mode = "noop"
        data = <<EOF
${TEMPLATE_REDIS}
EOF
        destination = "local/redis.conf"
      }

    }
  }
}
