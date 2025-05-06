output "lb_ip_address" {
  description = "IP address of the load balancer."
  value       = var.global ? google_compute_global_address.global_lb_ip[0].address : google_compute_address.regional_lb_ip[0].address
}

output "dns_name" {
  description = "DNS name (if created)."
  value       = var.create_dns ? google_dns_record_set.lb_dns[0].name : null
}

output "target_proxy" {
  description = "The self link of the target proxy (HTTP or HTTPS) based on the use_https variable."
  value = var.use_https ? (
    length(google_compute_target_https_proxy.global_https_proxy) > 0 ?
    google_compute_target_https_proxy.global_https_proxy[0].self_link : null
    ) : (
    length(google_compute_target_http_proxy.global_http_proxy) > 0 ?
    google_compute_target_http_proxy.global_http_proxy[0].self_link : null
  )
}

output "ssl_certificate_link" {
  description = "SSL cert self link (if used)."
  value = var.use_https ? (
    var.global ?
    try(google_compute_ssl_certificate.lb_ssl_cert_global[0].self_link, null)
    :
    try(google_compute_region_ssl_certificate.lb_ssl_cert_regional[0].self_link, null)
  ) : null
}


output "forwarding_rule_name" {
  description = "Name of the created forwarding rule."
  value = var.global ? (
    var.use_https && length(google_compute_global_forwarding_rule.https_global_lb_rule) > 0 ?
    google_compute_global_forwarding_rule.https_global_lb_rule[0].name :
    length(google_compute_global_forwarding_rule.http_global_lb_rule) > 0 ?
    google_compute_global_forwarding_rule.http_global_lb_rule[0].name :
    null
    ) : (
    var.use_https && length(google_compute_forwarding_rule.https_regional_lb_rule) > 0 ?
    google_compute_forwarding_rule.https_regional_lb_rule[0].name :
    length(google_compute_forwarding_rule.http_regional_lb_rule) > 0 ?
    google_compute_forwarding_rule.http_regional_lb_rule[0].name :
    null
  )
}