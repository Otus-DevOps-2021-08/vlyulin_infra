resource "yandex_lb_network_load_balancer" "vllb" {
  name = "vl-network-load-balancer"
  type = "external"

  listener {
    name = "vl-listener"
    port = 80
    target_port = 9292

    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.vl-lb-target-group.id

    healthcheck {
      name = "tcp"
      tcp_options {
        port = 9292
      }
    }
  }
}
