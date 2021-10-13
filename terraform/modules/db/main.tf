resource "yandex_compute_instance" "db" {
  name        = "reddit-db"
  platform_id = "standard-v2"

  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }

  labels = {
    tags = "reddit-db"
  }

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      # ”казать id образа созданного в предыдущем домашем задании
      image_id = var.db_disk_image
    }
  }

  network_interface {
    # ”казан id подсети default-ru-central1-a
    subnet_id = var.subnet_id
    nat       = true
  }
}
