# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

project = "nomad-jobspec-nodejs"

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
      buildkit           = false
      disable_entrypoint = true
      // platform           = "linux/arm64/v8"
    }
    registry {
      use "docker" {
        image = "hbgames/nodejs-jobspec-web"
        tag   = "latest" #gitrefpretty()
      }
    }
  }

  deploy {
    use "nomad-jobspec" {
      // Templated to perhaps bring in the artifact from a previous
      // build/registry, entrypoint env vars, etc.
      jobspec = templatefile("${path.app}/app.nomad.tpl", {})
    }
  }

  release {
    use "nomad-jobspec-canary" {
      groups          = ["app"]
      fail_deployment = false
    }
  }

  url {
    auto_hostname = true
  }
}