output "cluster_ip" {
  value = {for instance in yandex_compute_instance.vm:
            "${instance.name}" => "${instance.network_interface[0].nat_ip_address}"}
  description = "IP addresses of sockshop webpage"
}

output "srv_ip" {
  value = yandex_compute_instance.srv.network_interface[0].nat_ip_address
  description = "IP addresses of sockshop webpage"
}