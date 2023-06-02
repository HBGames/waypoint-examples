# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

project = "nomad-jobspec-nodejs"


runner {
  enabled = true

  data_source "git" {
    url  = "https://github.com/HBGames/waypoint-examples.git"
    path = "nomad/nodejs-jobspec"
  }
}

// pipeline "build-and-blue-green-deployment" {
//   step "build" {
//     use "build" {
//       disable_push = false
//     }
//   }

//   step "blue-green-deployment-pipeline" {
//     use "pipline" {
//       project = "nomad-jobspec-nodejs"
//       name    = "blue-green-deployment"
//     }
//   }
// }

// pipeline "blue-green-deployment" {
//   step "deploy" {
//     use "deploy" {}
//   }

//   step "split-traffic-to-green" {
//     image_url = "consul"

//     use "exec" {
//       command
//     }
//   }
// }

app "nodejs-jobspec-web" {
  build {
    use "docker" {
      buildkit           = true
      disable_entrypoint = true
      platform           = "linux/arm64/v8"
    }
    registry {
      use "docker" {
        image    = "hbgames/nodejs-jobspec-web"
        tag      = "latest" #gitrefpretty()
        username = var.registry_username
        password = var.registry_password
      }
    }
  }

  deploy {
    use "nomad-jobspec" {
      // Templated to perhaps bring in the artifact from a previous
      // build/registry, entrypoint env vars, etc.
      jobspec = templatefile("${path.app}/app.nomad.tpl", {
        registry_username = var.registry_username
        registry_password = var.registry_password
      })
    }
  }

  // release {
  //   use "nomad-jobspec-canary" {
  //     groups          = ["app"]
  //     fail_deployment = var.fail_deployment
  //   }
  // }

  url {
    auto_hostname = true
  }
}

variable "registry_username" {
  default = dynamic("vault", {
    path = "kv/data/docker"
    key  = "/data/username"
  })
  type        = string
  sensitive   = false
  description = "username for container registry"
}

variable "registry_password" {
  default = dynamic("vault", {
    path = "kv/data/docker"
    key  = "/data/password"
  })
  type        = string
  sensitive   = true # Notice this var is marked as sensitive
  description = "password for registry"
}

variable "fail_deployment" {
  type    = bool
  default = false
}