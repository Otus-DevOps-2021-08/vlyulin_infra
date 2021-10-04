provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zones[var.zone]
}

resource "yandex_compute_instance" "app" {
  count       = var.required_number_instances
  name        = "reddit-app-${count.index}"
  platform_id = "standard-v2"

  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      # ������� id ������ ���������� � ���������� ������� �������
      image_id = var.image_id
    }
  }

  network_interface {
    # ������ id ������� default-ru-central1-a
    subnet_id = var.subnet_id
    nat       = true
  }

  connection {
    type  = "ssh"
    host  = self.network_interface.0.nat_ip_address
    # yandex_compute_instance.app[count.index].network_interface.0.nat_ip_address
    user  = "ubuntu"
    agent = false
    # ���� �� ���������� �����
    private_key = file(var.private_key_path)
  }

  provisioner "file" {
    source      = "files/puma.service"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "files/deploy.sh"
  }
}
