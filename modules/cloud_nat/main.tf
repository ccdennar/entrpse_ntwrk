resource "google_compute_router" "router" {
  name    = var.router_name
  region  = var.region
  network = var.network_name

  bgp {
    asn = var.bgp_asn
  }
}

resource "google_compute_router_nat" "nat" {
  name                               = var.nat_name
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  dynamic "subnetwork" {
    for_each = var.nat_subnet_mapping  # or hardcode your GKE subnet
    content {
      name                    = subnetwork.value.self_link
      source_ip_ranges_to_nat = ["ALL_IP_RANGES"]   # covers primary + pods + services
    }
  }

  min_ports_per_vm = lookup(var.nat_config, "min_ports_per_vm", 128)
  log_config {
    enable = true
    filter = lookup(var.nat_config, "log_filter", "ERRORS_ONLY")
  }
}
