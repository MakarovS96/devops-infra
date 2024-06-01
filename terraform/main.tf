provider "yandex" {
  token                    = file(var.yandex_token_file)
  cloud_id                 = var.cloud
  folder_id                = var.folder
  zone                     = var.zonea
}

#Create network
resource "yandex_vpc_network" "sfnet" {
  name = "sfnet"
}

resource "yandex_vpc_subnet" "sfnetsub" {
  name = "sfnetsub"
  network_id = yandex_vpc_network.sfnet.id
  v4_cidr_blocks = ["10.0.0.0/24"]
}

#Create instances

resource "yandex_compute_instance" "vm" {

  count = var.instances_count

  name = "devops-sf-${count.index == 0 ? "manager": "worker-${count.index}"}"
  hostname = "devops-sf-${count.index == 0 ? "manager": "worker-${count.index}"}"

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      type = "network-ssd"
      size = 18
    }
  }

  allow_stopping_for_update = true

  resources {
    cores = 2
    memory = 2
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.sfnetsub.id
    nat = true
  }

  metadata = {
    ssh_keys="${var.ssh_user.name}:${file(var.ssh_user.pub_key)}"
    user-data=local.user_config
  }
}

# Create srv instance

resource "yandex_compute_instance" "srv" {

  name = "srv"
  hostname = "srv"

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      type = "network-ssd"
      size = 18
    }
  }

  allow_stopping_for_update = true

  resources {
    cores = 2
    memory = 2
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.sfnetsub.id
    nat = true
  }

  metadata = {
    ssh_keys="${var.ssh_user.name}:${file(var.ssh_user.pub_key)}"
    user-data=local.user_config
  }
}

