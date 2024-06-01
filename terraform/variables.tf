
variable "yandex_data" {
  description = "Yandex provider data"
  type = object({
    cloud = string
    folder = string
    zone = string
    token = string
  })
}

variable "ssh_user" {
  type = object({
    name = string
    private_key = string
    pub_key = string
  })
}

variable "instances_count" {
  type = number
  description = "Number of instances to up"
  default = 2
}

variable "github_data" {
  type = object({
    token = string
    repo = string
    account = string
  })
}