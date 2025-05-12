locals {
  is_internal = var.internal
  is_global   = var.global
  is_https    = var.use_https
}

# ========== IP Address ==========

resource "google_compute_global_address" "global_lb_ip" {
  count = local.is_global ? 1 : 0
  name  = "${var.name}-ip"
}

resource "google_compute_address" "regional_lb_ip" {
  count        = local.is_global ? 0 : 1
  name         = "${var.name}-ip"
  address_type = local.is_internal ? "INTERNAL" : "EXTERNAL"
  region       = var.region
  subnetwork   = local.is_internal ? var.subnetwork : null
}

# ========== SSL Certificate (if HTTPS) ==========

# Global SSL Certificate
resource "google_compute_ssl_certificate" "lb_ssl_cert_global" {
  count       = local.is_global && local.is_https ? 1 : 0
  name        = "${var.name}-ssl-cert-global"
  private_key = var.ssl_private_key
  certificate = var.ssl_certificate
}

# Regional SSL Certificate
resource "google_compute_region_ssl_certificate" "lb_ssl_cert_regional" {
  count       = !local.is_global && local.is_https ? 1 : 0
  name        = "${var.name}-ssl-cert-regional"
  region      = var.region
  private_key = var.ssl_private_key
  certificate = var.ssl_certificate
}

# ========== URL Maps ==========

# Global
resource "google_compute_url_map" "global_url_map" {
  count = local.is_global ? 1 : 0
  name  = "${var.name}-url-map-global"

  default_url_redirect {
    https_redirect  = local.is_https
    strip_query     = false
    prefix_redirect = "/"
  }
}

# Regional
resource "google_compute_region_url_map" "regional_url_map" {
  count  = local.is_global ? 0 : 1
  name   = "${var.name}-url-map-regional"
  region = var.region

  default_url_redirect {
    https_redirect  = local.is_https
    strip_query     = false
    prefix_redirect = "/"
  }
}

# ========== Target Proxies ==========

# Global External HTTP
resource "google_compute_target_http_proxy" "global_http_proxy" {
  count   = local.is_global && !local.is_internal && !local.is_https ? 1 : 0
  name    = "${var.name}-http-proxy-global"
  url_map = google_compute_url_map.global_url_map[0].self_link
}

# Global External HTTPS
resource "google_compute_target_https_proxy" "global_https_proxy" {
  count            = local.is_global && !local.is_internal && local.is_https ? 1 : 0
  name             = "${var.name}-https-proxy-global"
  url_map          = google_compute_url_map.global_url_map[0].self_link
  ssl_certificates = [google_compute_ssl_certificate.lb_ssl_cert_global[0].self_link]
}

# Regional External HTTP
resource "google_compute_region_target_http_proxy" "regional_http_proxy" {
  count   = !local.is_global && local.is_internal && !local.is_https ? 1 : 0
  name    = "${var.name}-http-proxy-regional-external"
  region  = var.region
  url_map = google_compute_region_url_map.regional_url_map[0].self_link
}

# Regional External HTTPS
resource "google_compute_region_target_https_proxy" "regional_https_proxy" {
  count            = !local.is_global && local.is_internal && local.is_https ? 1 : 0
  name             = "${var.name}-https-proxy-regional-external"
  region           = var.region
  url_map          = google_compute_region_url_map.regional_url_map[0].self_link
  ssl_certificates = [google_compute_region_ssl_certificate.lb_ssl_cert_regional[0].self_link]
}

# ========== Forwarding Rules ==========

# Global
resource "google_compute_global_forwarding_rule" "http_global_lb_rule" {
  count                 = var.global && !var.use_https && length(google_compute_target_http_proxy.global_http_proxy) > 0 ? 1 : 0
  name                  = "${var.name}-fr-global-http"
  ip_address            = google_compute_global_address.global_lb_ip[0].address
  ip_protocol           = var.protocol
  port_range            = var.port_range
  load_balancing_scheme = "EXTERNAL"
  target                = google_compute_target_http_proxy.global_http_proxy[0].self_link
}

resource "google_compute_global_forwarding_rule" "https_global_lb_rule" {
  count                 = var.global && var.use_https && length(google_compute_target_https_proxy.global_https_proxy) > 0 ? 1 : 0
  name                  = "${var.name}-fr-global-https"
  ip_address            = google_compute_global_address.global_lb_ip[0].address
  ip_protocol           = var.protocol
  port_range            = var.port_range
  load_balancing_scheme = "EXTERNAL"
  target                = google_compute_target_https_proxy.global_https_proxy[0].self_link
}


# Regional
resource "google_compute_forwarding_rule" "http_regional_lb_rule" {
  count                 = !var.global && !var.use_https && length(google_compute_region_target_http_proxy.regional_http_proxy) > 0 ? 1 : 0
  name                  = "${var.name}-fr-regional"
  region                = var.region
  ip_address            = google_compute_address.regional_lb_ip[0].address
  ip_protocol           = var.protocol
  port_range            = var.port_range
  load_balancing_scheme = local.is_internal ? "INTERNAL" : "EXTERNAL"
  network               = local.is_internal ? var.network : null
  subnetwork            = local.is_internal ? var.subnetwork : null

  target = google_compute_region_target_http_proxy.regional_http_proxy[0].self_link
}

resource "google_compute_forwarding_rule" "https_regional_lb_rule" {
  count                 = !var.global && var.use_https && length(google_compute_region_target_https_proxy.regional_https_proxy) > 0 ? 1 : 0
  name                  = "${var.name}-fr-regional"
  region                = var.region
  ip_address            = google_compute_address.regional_lb_ip[0].address
  ip_protocol           = var.protocol
  port_range            = var.port_range
  load_balancing_scheme = local.is_internal ? "INTERNAL" : "EXTERNAL"
  network               = local.is_internal ? var.network : null
  subnetwork            = local.is_internal ? var.subnetwork : null

  target = google_compute_region_target_https_proxy.regional_https_proxy[0].self_link
}

# ========== DNS Record ==========

resource "google_dns_record_set" "lb_dns" {
  count        = var.create_dns ? 1 : 0
  name         = "${var.dns_name}."
  type         = "A"
  ttl          = 300
  managed_zone = var.dns_zone
  rrdatas = [
    local.is_global ? google_compute_global_address.global_lb_ip[0].address : google_compute_address.regional_lb_ip[0].address
  ]
}