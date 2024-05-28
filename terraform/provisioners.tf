resource "local_file" "create_inventory" {
    depends_on = [ yandex_compute_instance.vm ]

    filename = "../ansible/inventory"

    content = templatefile("files/inventory.tmpl", {
        manager = yandex_compute_instance.vm[0].network_interface[0].nat_ip_address
        workers = [for worker in slice(yandex_compute_instance.vm, 1, var.instances_count): worker.network_interface[0].nat_ip_address]
    })
}

resource "null_resource" "wait_for_instances" {
    depends_on = [ yandex_compute_instance.vm, local_file.create_inventory]
    count = var.instances_count

    connection {
        type = "ssh"
        host = yandex_compute_instance.vm[count.index].network_interface[0].nat_ip_address
        user = var.ssh_user.name
        private_key = file(var.ssh_user.private_key)
    }

    provisioner "remote-exec" {
      inline = [ "echo Works!" ]
    }
}

resource "null_resource" "run_k8s_config" {
    depends_on = [ null_resource.wait_for_instances ]

    provisioner "local-exec" {
        command = "ansible-playbook -u sennin -i ../ansible/inventory --private-key ${var.ssh_user.private_key} ../ansible/preconf-play.yml"
    }
}

resource "null_resource" "run_master_node_config" {
    depends_on = [ null_resource.run_k8s_config ]

    provisioner "local-exec" {
        command = "ansible-playbook -u sennin -i ../ansible/inventory --private-key ${var.ssh_user.private_key} ../ansible/conf-k8s-manager-play.yml"
    }
}

resource "null_resource" "run_workers_node_config" {
    depends_on = [ null_resource.run_master_node_config ]

    provisioner "local-exec" {
        command = "ansible-playbook -u sennin -i ../ansible/inventory --private-key ${var.ssh_user.private_key} ../ansible/conf-k8s-workers-play.yml"
    }
}