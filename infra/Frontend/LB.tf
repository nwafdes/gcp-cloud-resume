
resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
  project = var.project_id
    disable_on_destroy = false
}
resource "google_project_service" "certificate_manager" {
  service = "certificatemanager.googleapis.com"
  project = var.project_id
  disable_on_destroy = false

}

resource "google_compute_global_address" "default" {
  project = var.project_id
  name = "sahaba-gcp-public-ip"
}

resource "google_compute_managed_ssl_certificate" "classic_cert" {
  name = "sahaba-classic-managed-cert"
  project = var.project_id
  managed {
    domains = ["gcp.sahabanet.com"]
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "google_compute_backend_bucket" "backend" {
  project = var.project_id
  
  name        = "sahaba-backend-bucket-for-urlmap"
  description = "My backend bucket for static content"
  bucket_name = var.bucket_name  
  enable_cdn  = true             
}

resource "google_compute_url_map" "urlmap" {
    depends_on = [ google_compute_backend_bucket.backend ]
  project = var.project_id

  name            = "sahaba-gcp-static-url-map"
  default_service = google_compute_backend_bucket.backend.id
}

resource "google_compute_target_https_proxy" "https_proxy" {
  project = var.project_id
  name               = "sahaba-https-proxy"
  url_map            = google_compute_url_map.urlmap.id
  ssl_certificates =  [google_compute_managed_ssl_certificate.classic_cert.id]
}

resource "google_compute_global_forwarding_rule" "https_rule" {
  project = var.project_id

  name                  = "sahaba-https-forwarding-rule"
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_global_address.default.address
  port_range            = "443"
  target                = google_compute_target_https_proxy.https_proxy.id
}


output "load_balancer_ip" {
  value = google_compute_global_address.default.address
}

