resource "local_file" "create_inventory" {
    depends_on = [ yandex_compute_instance.vm, yandex_compute_instance.srv ]

    filename = "../ansible/inventory"

    content = templatefile("files/inventory.tmpl", {
        manager = yandex_compute_instance.vm[0].network_interface[0].nat_ip_address
        workers = [for worker in slice(yandex_compute_instance.vm, 1, var.instances_count): worker.network_interface[0].nat_ip_address]
        srv = yandex_compute_instance.srv.network_interface[0].nat_ip_address
    })
}

resource "null_resource" "wait_for_cluster_instances" {
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

resource "null_resource" "wait_for_srv_instance" {
    depends_on = [ yandex_compute_instance.srv, local_file.create_inventory]

    connection {
        type = "ssh"
        host = yandex_compute_instance.srv.network_interface[0].nat_ip_address
        user = var.ssh_user.name
        private_key = file(var.ssh_user.private_key)
    }

    provisioner "remote-exec" {
      inline = [ "echo Works!" ]
    }
}

resource "null_resource" "run_preconf" {
    depends_on = [ null_resource.wait_for_cluster_instances, null_resource.wait_for_srv_instance ]

    provisioner "local-exec" {
        command = "ansible-playbook -u ${var.ssh_user.name} -i ../ansible/inventory --private-key ${var.ssh_user.private_key} ../ansible/preconf-all-play.yml"
    }
}

resource "null_resource" "run_srv_config" {
    depends_on = [ null_resource.run_preconf ]

    provisioner "local-exec" {
        environment = {
          USER = var.ssh_user.name
          PERSONAL_ACCESS_TOKEN = file(var.github_data.token)
          GITHUB_REPO = var.github_data.repo
          GITHUB_ACCOUNT = var.github_data.account
        }
        command = "ansible-playbook -u ${var.ssh_user.name} -i ../ansible/inventory --private-key ${var.ssh_user.private_key} ../ansible/preconf-srv-play.yml"
    }
}

resource "null_resource" "run_k8s_config" {
    depends_on = [ null_resource.run_preconf ]

    provisioner "local-exec" {
        command = "ansible-playbook -u ${var.ssh_user.name} -i ../ansible/inventory --private-key ${var.ssh_user.private_key} ../ansible/preconf-cluster-play.yml"
    }
}

resource "null_resource" "run_master_node_config" {
    depends_on = [ null_resource.run_k8s_config ]

    provisioner "local-exec" {
        command = "ansible-playbook -u ${var.ssh_user.name} -i ../ansible/inventory --private-key ${var.ssh_user.private_key} ../ansible/conf-k8s-manager-play.yml"
    }
}

resource "null_resource" "copy_kubeconfig" {

    depends_on = [ null_resource.run_master_node_config ]

    connection {
        type = "ssh"
        host = yandex_compute_instance.vm[0].network_interface[0].nat_ip_address
        user = var.ssh_user.name
        private_key = file(var.ssh_user.private_key)
    }

    provisioner "local-exec" {
      command = "scp -i ${var.ssh_user.private_key} ${var.ssh_user.name}@${yandex_compute_instance.vm[0].network_interface[0].nat_ip_address}:~/.kube/config ../.keys/kubeconfig"
    }

    provisioner "local-exec" {
      command = "sed -i '' 's/${yandex_compute_instance.vm[0].network_interface[0].ip_address}/${yandex_compute_instance.vm[0].network_interface[0].nat_ip_address}/g' '../.keys/kubeconfig'"
    }

}

resource "null_resource" "run_workers_node_config" {
    depends_on = [ null_resource.run_master_node_config ]

    provisioner "local-exec" {
        command = "ansible-playbook -u ${var.ssh_user.name} -i ../ansible/inventory --private-key ${var.ssh_user.private_key} ../ansible/conf-k8s-workers-play.yml"
    }
}

resource "null_resource" "clear_gh_runners" {
    depends_on = [yandex_compute_instance.srv, local_file.create_inventory]
    triggers = {
        user = var.ssh_user.name
        token = file(var.github_data.token)
        repo = var.github_data.repo
        account = var.github_data.account
        private_key = var.ssh_user.private_key
    }

    provisioner "local-exec" {
        when = destroy
        on_failure = continue

        environment = {
            USER = self.triggers.user
            PERSONAL_ACCESS_TOKEN = self.triggers.token
            GITHUB_REPO = self.triggers.repo
            GITHUB_ACCOUNT = self.triggers.account
        }
        command = "ansible-playbook -u ${self.triggers.user} -i ../ansible/inventory --private-key ${self.triggers.private_key} ../ansible/on-destroy-srv-play.yml"
    }
}