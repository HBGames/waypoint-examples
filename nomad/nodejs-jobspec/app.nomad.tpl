job "${app.name}" {
  name        = "${app.name}"
  region      = "eu-central"
  datacenters = ["eu-central-1"]

  group "app" {
    count = 1

    update {
      max_parallel = 1
      canary       = 1
      auto_revert  = true
      auto_promote = false
      health_check = "task_states"
    }

    network {
      mode = "bridge"
      port "http" {
        host_network = "private"
      }
    }

    task "app" {
      driver = "docker"
      config {
        image = "${artifact.image}:${artifact.tag}"
        ports = ["http"]
      }

      env {
        %{ for k,v in entrypoint.env ~}
        ${k} = "${v}"
        %{ endfor ~}
      }

      template {
        data        = <<EOH
PORT={{ env "NOMAD_PORT_http"}}
        EOH
        destination = "local/env"
        env         = true
      }

      resources {
        cpu    = 50
        memory = 100
      }
    }

    shutdown_delay = "1m"

    service {
      name = "${app.name}"
      port = "http"

      check {
        type     = "http"
        path     = "/"
        interval = "3s"
        timeout  = "1s"
      }

      tags = [
        "traefik.enable=true",
        "traefik.consulcatalog.connect=true",
        "traefik.http.routers.${app.name}.tls=true",
        "traefik.http.routers.${app.name}.entrypoints=https",
        "traefik.http.routers.${app.name}.rule=Host(`${app.name}.hitbox.cloud`)",
        "traefik.http.services.${app.name}.loadBalancer.server.scheme=http",
        "cloudflare.domain=${app.name}.hitbox.cloud",
        "version=${artifact.tag}",
        "blue"
      ]

      canary_tags = ["green"]

      connect {
        sidecar_service {}
      }
    }
  }

  meta = {
    version = "${artifact.tag}"
    // Ensure we set meta for Waypoint to detect the release URL
    "waypoint.hashicorp.com/release_url" = "https://app--${artifact.tag}.hitbox.cloud"
  }
}
