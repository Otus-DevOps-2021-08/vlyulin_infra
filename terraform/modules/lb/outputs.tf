output "lb_network_ip_address" {
  value = yandex_lb_network_load_balancer.vllb.listener.*.external_address_spec[0].*.address
}
