variable "folder" {
  type = string
  description = "YC folder id"
}

variable "cloud" {
  type = string
  description = "YC cloud id"
}

variable "zone" {
  type = string
  description = "YC zone name"
}

variable "yandex_token_file" {
  type = string
  description = "path to file with your yandex cloud token"
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