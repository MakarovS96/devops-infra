terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.119.0"
    }
    null = {
      source = "hashicorp/null"
      version = "3.2.2"
    }
    local = {
      source = "hashicorp/local"
      version = "2.5.1"
    }
  }
}