# Ingress gateway - look into
# https://www.hashicorp.com/blog/introducing-hashicorp-nomad-v0-12-s-new-consul-ingress-gateway-capability

job "job" {
  datacenters = ["dc1"]

  constraint {
    attribute = "${node.class}"
    value = "worker"
  }

  group "web" {
    count = 1
    
    # Mode MUST be "host"
    # Bridge and CNI use iptables to create isolated namespace
    # This allocates a port from the host_netowrk interface
    # Docker manages the routing of that allocation to the container port
    network {
      mode = "host"
      port "random" {
        to = 3000
        # Defined in Nomad client config
        host_network = "private"
      }
    }

    task "task" {
      driver = "docker"

      service {
        id = "service"
        name = "service"

        # Mode MUST be host when using multiple servers (subnet range is not unique)
        # Advertises the IP and port from Nomad's host_network allocation
        address_mode = "host"
        port = "random"
      }

      config {
        image = "us-docker.pkg.dev"
        
        # Assigns container an IP from docker0 interface range
        # Dynamically creates nftables rule to route random host port to containter port
        network_mode = "bridge"
        ports = ["random"]
      }
    }
  }
}
