resource "local_file" "create_inventory" {
    depends_on = [ yandex_compute_instance.vm ]

    filename = "../ansible/inventory"

    content = templatefile("files/inventory.tmpl", {
        manager = yandex_compute_instance.vm[0].network_interface[0].nat_ip_address
        workers = [for worker in slice(yandex_compute_instance.vm, 1, var.instances_count): worker.network_interface[0].nat_ip_address]
    })
}

/*resource "null_resource" "docker-swarm-manager-init" {
    depends_on = [ yandex_compute_instance.manager ]

    connection {
        type = "ssh"
        host = yandex_compute_instance.manager.network_interface[0].nat_ip_address
        user = var.ssh_user.name
        private_key = file(var.ssh_user.private_key)
    }

    provisioner "file" {
      source = "../docker-compose.yml"
      destination = "docker-compose.yml"
    }

    provisioner "local-exec" {
        command = "ansible-playbook -u sennin -i '${yandex_compute_instance.manager.network_interface[0].nat_ip_address},' --private-key ${var.ssh_user.private_key} ansible/docker-install-playbook.yml"
    }

    provisioner "local-exec" {
        command = "ansible-playbook -u sennin -i '${yandex_compute_instance.manager.network_interface[0].nat_ip_address},' --private-key ${var.ssh_user.private_key} ansible/docker-swarm-manager-playbook.yml"
    }
}

resource "null_resource" "docker-swarm-worker-get-token" {
    depends_on = [ yandex_compute_instance.manager, null_resource.docker-swarm-manager-init ]
    connection {
        type = "ssh"
        host = yandex_compute_instance.manager.network_interface[0].nat_ip_address
        user = var.ssh_user.name
        private_key = file(var.ssh_user.private_key)
    }

    provisioner "local-exec" {
        command = "echo $(ssh -i ${var.ssh_user.private_key} -o StrictHostKeyChecking=no ${var.ssh_user.name}@${yandex_compute_instance.manager.network_interface[0].nat_ip_address} docker swarm join-token -q worker) > keys/swarm_token"
    }
}

resource "local_file" "docker-swarm-worker-ansible" {
  depends_on = [ null_resource.docker-swarm-worker-get-token, data.local_file.swarm_token ]
  filename = "ansible/docker-swarm-worker-playbook.yml"
  content = templatefile("ansible/docker-swarm-worker-playbook.yml.tmpl", {"address": yandex_compute_instance.manager.network_interface[0].ip_address, "swarm_token": trimspace(data.local_file.swarm_token.content)})
}

resource "null_resource" "docker-swarm-worker1-join" {
    depends_on = [ yandex_compute_instance.worker1, local_file.docker-swarm-worker-ansible ]
    connection {
        type = "ssh"
        host = yandex_compute_instance.worker1.network_interface[0].nat_ip_address
        user = var.ssh_user.name
        private_key = file(var.ssh_user.private_key)
    }

    provisioner "local-exec" {
        command = "ansible-playbook -u sennin -i '${yandex_compute_instance.worker1.network_interface[0].nat_ip_address},' --private-key ${var.ssh_user.private_key} ansible/docker-install-playbook.yml"
    }

    provisioner "local-exec" {
        command = "ansible-playbook -u sennin -i '${yandex_compute_instance.worker1.network_interface[0].nat_ip_address},' --private-key ${var.ssh_user.private_key} ansible/docker-swarm-worker-playbook.yml"
    }
}

resource "null_resource" "docker-swarm-worker2-join" {
    depends_on = [ yandex_compute_instance.worker1, local_file.docker-swarm-worker-ansible ]
    connection {
        type = "ssh"
        host = yandex_compute_instance.worker2.network_interface[0].nat_ip_address
        user = var.ssh_user.name
        private_key = file(var.ssh_user.private_key)
    }

    provisioner "local-exec" {
        command = "ansible-playbook -u sennin -i '${yandex_compute_instance.worker2.network_interface[0].nat_ip_address},' --private-key ${var.ssh_user.private_key} ansible/docker-install-playbook.yml"
    }

    provisioner "local-exec" {
        command = "ansible-playbook -u sennin -i '${yandex_compute_instance.worker2.network_interface[0].nat_ip_address},' --private-key ${var.ssh_user.private_key} ansible/docker-swarm-worker-playbook.yml"
    }
}

resource "null_resource" "docker-swarm-manager-start" {
    depends_on = [ yandex_compute_instance.manager, null_resource.docker-swarm-worker1-join, null_resource.docker-swarm-worker2-join ]

    connection {
        type = "ssh"
        host = yandex_compute_instance.manager.network_interface[0].nat_ip_address
        user = var.ssh_user.name
        private_key = file(var.ssh_user.private_key)
    }

    provisioner "remote-exec" {
        inline = [
            "docker stack deploy --compose-file docker-compose.yml sockshop-swarm"
         ]
    }
}*/