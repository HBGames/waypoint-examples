# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

project = "nomad-nodejs"

app "nomad-nodejs-web" {

  build {
    use "docker" {}
    registry {
      use "docker" {
        image = "registry.hub.docker.com/hbgames/nodejs-jobspec-web"
        tag   = "latest"
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
