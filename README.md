## Terraform GCP Load Balancer 

[![Opstree Solutions][opstree_avatar]][opstree_homepage]<br/>[Opstree Solutions][opstree_homepage] 

  [opstree_homepage]: https://opstree.github.io/
  [opstree_avatar]: https://img.cloudposse.com/150x150/https://github.com/opstree.png

This Terraform configuration dynamically provisions a Google Cloud Load Balancer—either Global or Regional, based on input variables. It conditionally creates IP addresses, SSL certificates, URL maps, proxies, forwarding rules, and DNS records depending on whether the load balancer is internal, global, or uses HTTPS. The use of count and locals allows for flexible and environment-specific infrastructure provisioning.

## Architecture

<img width="6000" length="8000" alt="Terraform" src="https://github.com/user-attachments/assets/26c523f3-290d-4be9-bc8b-39fbca89478b">



## Providers

| Name                                              | Version  |
|---------------------------------------------------|----------|
| <a name="provider_gcp"></a> [gcp](#provider\_gcp) | 5.0.0   |

## Usage

```hcl
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

```

## Inputs

| Name | Description | Type | Default | Required | 
|------|-------------|:----:|---------|:--------:|
|**project_id**| The ID of the project for which the resource is to be configured | string | { } | yes| 
|**region**| The Google Cloud region | string | us-central1 | yes | 
|**name**| Name of the Load Balancer | string | { } |yes| 
|**use_https**| Whether to use HTTPS (true) or HTTP (false) | bool | false | yes| 
|**create_dns** | Whether to create DNS records | bool | true | yes|
|**dns_name**| DNS name for the Load Balancer | string | { } | yes | 
|**dns_zone**| Managed DNS Zone for the record | string | { } | yes| 
|**protocol**| Protocol for the Load Balancer | string | "TCP" | yes| 
|**port_range** | Port range for the Load Balancer | string | " " | yes|
|**network**| VPC network name | string | { } | yes | 
|**subnetwork**| Subnetwork name | string | { } | yes|
|**internal**| True for Internal LB, false for External | bool | false | yes| 
|**global** | True for Global LB, false for Regional | bool | false | yes|
|**ssl_private_key**| SSL private key (for HTTPS) | string | { } | yes | 
|**ssl_certificate**| SSL certificate (for HTTPS) | string | { } | yes|


## Output
| Name | Description |
|------|-------------|
|**lb_ip_address**| IP address of the load balancer | 
|**dns_name**| DNS Name |
|**target_proxy**| The self link of the target proxy (HTTP or HTTPS) based on the use_https variable |
|**ssl_certificate_link**| SSL cert self link |
| **forwarding_rule_name** | Name of the created forwarding rule |
                                                                                                              