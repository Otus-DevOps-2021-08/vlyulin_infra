provider "yandex" {
  version                  = "~> 0.56"
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zones[var.zone]
}

module "vpc" {
  source = "../modules/vpc"
}

module "db" {
  source                = "../modules/db"
  public_key_path       = var.public_key_path
  db_disk_image         = var.db_disk_image
  subnet_id             = "${module.vpc.subnet_id}"
}

module "app" {
  source                    = "../modules/app"
  public_key_path           = var.public_key_path
  private_key_path          = var.private_key_path
  app_disk_image            = var.app_disk_image
  required_number_instances = var.required_number_instances
  subnet_id                 = "${module.vpc.subnet_id}"
  database_ip               = "${module.db.external_ip_address_db}"
  provisioners_required     = var.provisioners_required
}


module "lb" {
  folder_id               = var.folder_id
  region_id               = var.region_id
  source                  = "../modules/lb"
  subnet_id               = "${module.vpc.subnet_id}"
  internal_ip_address_app = "${module.app.internal_ip_address_app}"
  lb_port                 = var.lb_port
}

# generate inventory file for Ansible
resource "local_file" "hosts_cfg" {
  content = templatefile("${path.module}/../templates/hosts.tpl",
    {
      app_ips = module.app.external_ip_address_app
      db_ips = list(module.db.external_ip_address_db)
    }
  )
  filename = "../../ansible/environments/stage/stage_hosts.cfg"
}
