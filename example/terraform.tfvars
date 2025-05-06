region = "us-central1"

project_id = "nw-opstree-dev-landing-zone"

name = "my-lb"

use_https = false # Set to true for HTTPS, false for HTTP

create_dns = true # Set to true if you want DNS records

dns_name = "my-lb.example.com"

dns_zone = "lb-dns-zone"

protocol = "TCP"

port_range = "443" # Use port 443 for HTTPS

internal = false # Use true for internal LB, false for external

global = false # Use true for global, false for regional

ssl_private_key = "ssl private key"

ssl_certificate = "ssl certificate"

network = "default"

subnetwork = "default"
