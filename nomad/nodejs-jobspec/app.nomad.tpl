job "web" {
  datacenters = ["eu-central-1"]
  group "app" {
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
        to           = 3000
        host_network = "public"
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

        // For URL service
        PORT = "3000"
      }

      resources {
        cpu    = 50
        memory = 100
      }
    }

    service {
      name = "app"
      port = "http"

      tags = [
        "traefik.enable=true",
        "traefik.consulcatalog.connect=true",
        "traefik.http.routers.app.tls=false",
        "traefik.http.routers.app.entrypoints=https",
        "traefik.http.routers.app.rule=Host(`app.hitbox.cloud`)",
        "traefik.http.services.app.loadBalancer.server.scheme=http"
      ]

      connect {
        sidecar_service {}
      }
    }
  }

  meta {
    "waypoint.hashicorp.com/release_url" = "https://app.hitbox.cloud"
  }
}
