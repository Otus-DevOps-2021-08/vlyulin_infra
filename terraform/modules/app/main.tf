resource "yandex_compute_instance" "app" {
  count       = var.required_number_instances
  name        = "reddit-app-${count.index}"
  platform_id = "standard-v2"

  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }

  labels = {
    tags = "reddit-app"
  }

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      # ”казать id образа созданного в предыдущем домашем задании
      image_id = var.app_disk_image
    }
  }

  network_interface {
    # ”казан id подсети default-ru-central1-a
    subnet_id = var.subnet_id
    nat       = true
  }

  depends_on = [var.database_ip]
}

# https://medium.com/@business_99069/terraform-count-vs-for-each-b7ada2c0b186
# https://discuss.hashicorp.com/t/conditional-for-each-resources/10322/4
locals {
    lvar_instances_ips = var.provisioners_required ? toset(yandex_compute_instance.app.*.network_interface.0.nat_ip_address) : toset([])
}

resource "null_resource" "inst_reddit" {
    # count = var.provisioners_required ? 1 : 0
    for_each = local.lvar_instances_ips
    # for_each = toset(yandex_compute_instance.app.*.network_interface.0.nat_ip_address)

    triggers = {
      list_value_ip = each.value
    }

    connection {
      type  = "ssh"
      # host  = self.network_interface.0.nat_ip_address
      # host  = "${yandex_compute_instance.app.*.id}"
      host  = each.value
      user  = "ubuntu"
      agent = false
      # путь до приватного ключа
      private_key = file(var.private_key_path)
    }

    provisioner "file" {
      content     = templatefile("${path.module}/files/puma.service.tmpl", { database_ip = var.database_ip })
      destination = "/tmp/puma.service"
    }

    provisioner "remote-exec" {
      script = "${path.module}/files/deploy.sh"
    }
}
