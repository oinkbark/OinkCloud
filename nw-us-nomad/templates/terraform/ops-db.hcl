job "ops-db" {
  type = "service"
  datacenters = ["dc1"]

  constraint {
    attribute = "$${node.class}"
    value = "worker"
  }

  group "persistent" {
    count = 1

    # HTTPS = 7473
    # https://neo4j.com/docs/operations-manual/current/configuration/ports/
    network {
      mode = "host"
      port "ops-neo4j-https" {
        to = 7473
        host_network = "private"
      }
      port "ops-neo4j-bolt" {
        to = 7687
        host_network = "private"
      }
    }
  
    task "neo4j" {
      service {
        id = "ops-neo4j"
        name = "ops-neo4j"
        port = "ops-neo4j-https"
        tags = [ "https" ]
        address_mode = "host"
      }
      service {
        id = "ops-neo4j-bolt"
        name = "ops-neo4j-bolt"
        port = "ops-neo4j-bolt"
        tags = [ "bolt" ]
        address_mode = "host"
      }

      resources {
        # Operational minimum = 2048
        memory = 2048
      }

      env {
        # Default Connection
        NEO4J_AUTH = "neo4j/${NEO4J_PASSWORD}"
        NEO4J_dbms_default__listen__address = "0.0.0.0"
        NEO4J_dbms_connector_http_enabled = false

        # Bolt Connection
        NEO4J_dbms_connector_bolt_listen__address = ":7687"
        NEO4J_dbms_connector_bolt_advertised__address = "direct.oinkcloud.com:7687"

        # HTTP TLS
        NEO4J_dbms_connector_https_enabled = true
        NEO4J_dbms_ssl_policy_https_enabled = true
        NEO4J_dbms_ssl_policy_https_client__auth = "NONE"
        NEO4J_dbms_ssl_policy_https_private__key = "neo4j.key"
        NEO4J_dbms_ssl_policy_https_public__certificate = "neo4j.crt"

        # Bolt TLS
        NEO4J_dbms_connector_bolt_tls__level = "OPTIONAL"
        NEO4J_dbms_ssl_policy_bolt_enabled = true
        NEO4J_dbms_ssl_policy_bolt_client__auth = "NONE"
        NEO4J_dbms_ssl_policy_bolt_private__key = "neo4j.key"
        NEO4J_dbms_ssl_policy_bolt_public__certificate = "neo4j.crt"

        # Directories
        NEO4J_dbms_ssl_policy_bolt_base__directory = "/var/lib/neo4j/certificates"
        NEO4J_dbms_ssl_policy_https_base__directory = "/var/lib/neo4j/certificates"
      }

      # cypher-shell -u neo4j -p <password>
      driver = "docker"
      config {
        image = "neo4j:4.3.3-community"
        network_mode = "bridge"
        ports = [ "ops-neo4j-https", "ops-neo4j-bolt" ]
        // bind mount using --mount does not create host dir
        // bind mount using --volume does
        volumes = [
          "/root/neo4j/data:/data",
          "/root/neo4j/logs:/logs",
          "/root/neo4j/import:/var/lib/neo4j/import"
        ]

        # chown: changing ownership of '/var/lib/neo4j/conf/neo4j.conf': Read-only file system
        //mount {
        //  type = "bind"
        //  source = "/root/ops /neo4j/data"
        //  target = "/data"
        //}
        // "/root/OinkServer/runtime/worker-service.consul-tls.crt"
        mount {
         type = "bind"
         readonly = false
         source = "/root/OinkServer/runtime/worker-service.consul-tls.crt"
         target = "/var/lib/neo4j/certificates/neo4j.crt"
        }
        mount {
         type = "bind"
         readonly = false
         source = "/root/OinkServer/runtime/worker-service.consul-tls.key"
         target = "/var/lib/neo4j/certificates/neo4j.key"
        }
      }
    }
  }
}
