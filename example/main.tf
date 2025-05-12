module "load_balancer" {
  source = "./module"
  name            = var.name
  use_https       = var.use_https
  create_dns      = var.create_dns
  dns_name        = var.dns_name
  dns_zone        = var.dns_zone
  protocol        = var.protocol
  port_range      = var.port_range
  internal        = var.internal
  global          = var.global
  ssl_private_key = var.ssl_private_key
  ssl_certificate = var.ssl_certificate
  region          = var.region
  network         = var.network
  subnetwork      = var.subnetwork
}