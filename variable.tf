variable "name" {
  description = "Name of the Load Balancer."
  type        = string
}

variable "use_https" {
  description = "Whether to use HTTPS (true) or HTTP (false)."
  type        = bool
  default     = false
}

variable "create_dns" {
  description = "Whether to create DNS records."
  type        = bool
  default     = true
}

variable "dns_name" {
  description = "DNS name for the Load Balancer."
  type        = string
}

variable "dns_zone" {
  description = "Managed DNS Zone for the record."
  type        = string
}

variable "protocol" {
  description = "Protocol for the Load Balancer (TCP, UDP)."
  type        = string
  default     = "TCP"
}

variable "port_range" {
  description = "Port range for the Load Balancer."
  type        = string
}

variable "internal" {
  description = "True for Internal LB, false for External."
  type        = bool
  default     = false
}

variable "global" {
  description = "True for Global LB, false for Regional."
  type        = bool
  default     = false
}

variable "ssl_private_key" {
  description = "SSL private key (for HTTPS)."
  type        = string
  sensitive   = true
  default     = ""
}

variable "ssl_certificate" {
  description = "SSL certificate (for HTTPS)."
  type        = string
  sensitive   = true
  default     = ""
}

variable "region" {
  description = "Region for regional resources."
  type        = string
}

variable "network" {
  description = "VPC network name (for internal LB)."
  type        = string
}

variable "subnetwork" {
  description = "Subnetwork name (for internal LB)."
  type        = string
}