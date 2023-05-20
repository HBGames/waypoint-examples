# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

project = "nomad-jobspec-nodejs"

app "nodejs-jobspec-web" {
  build {
    use "docker" {}
    registry {
      use "docker" {
        image    = "registry.hub.docker.com/hbgames/nodejs-jobspec-web"
        tag      = "latest"
        username = var.registry_username
        password = var.registry_password
      }
    }
  }

  deploy {
    use "nomad-jobspec" {
      // Templated to perhaps bring in the artifact from a previous
      // build/registry, entrypoint env vars, etc.
      jobspec = templatefile("${path.app}/app.nomad.tpl")
    }
  }

  release {
    use "nomad-jobspec-canary" {
      groups          = ["app"]
      fail_deployment = false
    }
  }
}

variable "registry_username" {
  type        = string
  sensitive   = false
  description = "username for container registry"
}

variable "registry_password" {
  type        = string
  sensitive   = true # Notice this var is marked as sensitive
  description = "password for registry"
}