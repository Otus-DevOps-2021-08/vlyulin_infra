variable folder_id {
  description = "Folder id"
}
variable region_id {
  description = "Region id"
}
variable target_port {
  type = number
  description = "target http port"
  default     = 9292
}
variable lb_port {
  type = number
  description = "http port"
  default     = 80
}
variable subnet_id {
  description = "Subnets for modules"
}
variable internal_ip_address_app {
  type        = list(string)
  description = "List of ip addresses"
}
