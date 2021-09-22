job "${DOMAIN_NAME}-ssl" {
  type = "batch"
  datacenters = ["dc1"]

  constraint {
    attribute = "$${node.class}"
    value = "leader"
  }

  periodic {
    cron = "@daily"
    prohibit_overlap = true
  }

  group "dns-certificate" {
    count = 1

    network {
      mode = "host"
    }

    task "certbot" {
      service {
        name = "${DOMAIN_NAME}-certbot"
        address_mode = "host"
      }

      restart {
        attempts = 2
        delay = "10s"
        interval = "60m"
      }
  
      driver = "docker"
      config {
        image = "certbot/dns-cloudflare"

        mount {
          type = "bind"
          readonly = true
          source = "secrets/task/cloudflare-keys.ini"
          target = "/root/cloudflare-keys.ini"
        }
        mount {
          type = "bind"
          readonly = false
          source = "/mnt/nw_us_leader/etc/letsencrypt"
          target = "/etc/letsencrypt"
        }
        logging {
          type = "gcplogs"
          config {
            mode = "non-blocking"
            gcp-project = "oinkserver"
          }
        }
  
        command = "certonly"
        args = [
          "--preferred-challenges", "dns",
          "--dns-cloudflare", 
          "--dns-cloudflare-propagation-seconds", "20",
          "--dns-cloudflare-credentials", "/root/cloudflare-keys.ini",
          "--non-interactive", 
          "--agree-tos",
          "--email", "tls@oinkcloud.com",
          "--keep",
          "--staple-ocsp", 
          "--must-staple", 
          "--uir",
          "--deploy-hook", "echo $(date) > /etc/letsencrypt/last-renew",
          "--domain", "${DOMAIN_NAME}.${DOMAIN_TLD}",
          "--domain", "*.${DOMAIN_NAME}.${DOMAIN_TLD}"
        ]
      }
      template {
        change_mode = "noop"
        data = file("nw-us-nomad/templates/secrets/${DOMAIN_NAME}-ssl/cloudflare-keys.ini")
        destination = "secrets/task/cloudflare-keys.ini"
      }
    }
  }
}
