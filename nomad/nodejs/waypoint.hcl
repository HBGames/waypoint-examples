# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

project = "nomad-nodejs"

app "nomad-nodejs-web" {

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
    use "nomad" {
      // these options both default to the values shown, but are left here to
      // show they are configurable
      datacenter = "eu-central-1"
      namespace  = "default"
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
