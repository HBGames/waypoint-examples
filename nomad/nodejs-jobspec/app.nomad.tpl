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
        to = 3000
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
    }

    service {
      name = "app"
      port = 3000
      connect {
        sidecar_service {}
      }
    }
  }
}
