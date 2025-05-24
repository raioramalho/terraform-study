terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

resource "docker_image" "postgres" {
  name = "postgres:latest"
}

resource "docker_container" "postgres" {
  image = docker_image.postgres.name
  name  = "postgres-server"
  env = [
    "POSTGRES_PASSWORD=examplepassword"
  ]
  ports {
    internal = 5432
    external = 5432
  }

  volumes {
    host_path      = "/Users/raiodev/Developer/terraform-study/docker/postgresql/data"
    container_path = "/var/lib/postgresql/data"
  }
}
