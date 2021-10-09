variable folder_id {
  description = "Folder id"
}
variable region_id {
  description = "Region id"
}
variable lb_port {
  description = "http port"
  default     = "80"
}
variable subnet_id {
  description = "Subnets for modules"
}
variable external_ip_address_app {
  type        = list(string)
  description = "List of ip addresses"
}
