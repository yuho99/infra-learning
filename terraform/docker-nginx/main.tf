terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

resource "docker_image" "nginx" {
  name = "nginx:alpine"   # ← latest から alpine に変更
}

resource "docker_container" "web" {
  name  = "web-1"
  image = docker_image.nginx.image_id

  ports {
    internal = 80
    external = 8091 # ← 空いているポートに変更
  }
}
