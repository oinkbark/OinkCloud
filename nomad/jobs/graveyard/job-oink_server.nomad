 
job "oinkserver" {
  region = "global"
  datacenters=["dc1"]
  type="service"

  # Only run on linux
  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }

  restart {
  }

  spread {
  }

  # How job updates new tasks
  update {
    # Do not update all tasks at once
    max_parallel = 1

    # How long to wait between each
    stagger = "30s"

    # Time until alloc is marked as healthy
    min_healthy_time = "10s"
    # How long alloc has to become healthy can
    # Can trigger job rollback if auto_revert set to true
    healthy_deadline = "3m"
    # At least 1 alloc must be marked as healthy by this time
    progress_deadline = "10m"

    # Downgrade job if new jobs cannot all become healthy
    auto_revert = "true"

  }

  # Group of tasks that must always exist on same machine together

  # Distribute functions to logic servers.

  # Key-server (stateless)
  # All requests must flow through this, DB cannot respond directly to client request
  # All other groups should esentially be air gapped and only run through this
  # - Decreases attack surface
  # 100% should be its own server
  # FIgure out balance between self andw cloudflare
  # Option 1: forward request straight to destination
  # Option 2: Analyze request and be the broker (like a VPN); request data from destination itself and then serve it back
  # Option 2 has greater security benefits and easier caching?
  group "router" {
    # Custom key values
    meta {

    }

    # Can be on job, group, or task level
    # Required policies to access
    #vault {
    #  policies = [""]
    #}

    # Physical needs: Fast processor, low disk space, lots of RAM (high requests)
    # How many instances to run
    count = 1

    # - Connect visitors to key servers, and key servers to logic servers.
    # AUTO_IMPORT=nginx

    # - Connect key server to logging DB server (fowards logs from logic servers, sends self logs).
    # AUTO_IMPORT=fluentd

    # - API; send automated requests to right place (usually DB)
    #

    # - Vault; make sure requester has ability to access requested resource before routing to it
    # AUTO_IMPORT=vault

    # - Consul; service discovery (Connect logic servers to router without hardcoding IP addresses)
    # AUTO_IMPORT=consul

    # - RabbitMQ; Message queue broker (routes messages to correct destinations)
    # -- Semi stateful though
    # AUTO_IMPORT=
  }

  # Data-server (semi-stateful)
  # Can be built into db? or is proper separation needed? is this just a different db?
  group "renderer" {
    # Physical needs: Lots of ram, no disk, medium processor (medium-high requests)
    count = 1

    # - Serves cached, pre-rendered views to router, who then sends them to client
    # - Mostly stateless, views/components are stored in db?
    # AUTO_IMPORT=nodejs
  }

  # Data-server (stateful; cannot be easily rebuilt without backups)
  group "database" {
    # Physical needs: fast processor, large amounts of fast disk space (medium requests)
    count = 1

    # AUTO_IMPORT=mongo
    # AUTO_IMPORT=neo4j
  }

  # Data-server (semi stateful; can be destroyed and rebuilt halfway simply, but you are rebuilding artifact state)
  # Instead of using Terraform built in function to fetch images, the images will be stored on a server
  # Terraform can then be pointed to that server to fetch saved docker tar file from
  # (rather than exposing each server to open network to fetch images, just one builds them and can send them over local)
  # - also saves on data transfer costs
  group "versioner" {
    # Physical needs: large amount of disk space (low requests)

    # - Stores cached, pre-built Docker images
    # AUTO_IMPORT=registry
    # - Stores cached, pre-tested raw production source code
  }
}
