variable public_key_path {
  # Описание переменной
  description = "Path to the public key used for ssh access"
}
variable private_key_path {
  # Описание переменной
  description = "Path to the private key used for ssh access"
}
variable required_db_number_instances {
  description = "Required db number of instances"
  default     = 1
}
variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
}
variable subnet_id {
  description = "Subnets for modules"
}
variable required_number_instances {
  description = "Required number of instances"
  default     = 1
}
variable database_ip {
  description = "Database ip"
}
