terraform {
  cloud {
    organization = "justinrubek"

    workspaces {
      name = "minio"
    }
  }

  required_providers {
    minio = {
      source  = "aminueza/minio"
      version = "1.17.2"
    }
  }

  required_version = ">= 1.0"
}
