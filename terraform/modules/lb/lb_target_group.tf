resource "yandex_lb_target_group" "vl-lb-target-group" {
  name      = "vl-target-group"
  region_id = var.region_id
  folder_id = var.folder_id

  dynamic "target" {
    for_each = var.internal_ip_address_app
    content {
      subnet_id = "${var.subnet_id}"
      address   = target.value
    }
  }
}
