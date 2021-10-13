output "external_ip_address_app" {
  value = module.app.external_ip_address_app
}
output "external_ip_address_db" {
  value = module.db.external_ip_address_db
}
output "lb_network_ip_address" {
  value = module.lb.lb_network_ip_address
}
