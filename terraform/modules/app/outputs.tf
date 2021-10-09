output "external_ip_address_app" {
  value = "${yandex_compute_instance.app[*].network_interface.0.ip_address}"
}
