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
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  min_ports_per_vm = lookup(var.nat_config, "min_ports_per_vm", 128)
  max_ports_per_vm = lookup(var.nat_config, "max_ports_per_vm", 1024)
  
  enable_dynamic_port_allocation = lookup(var.nat_config, "enable_dynamic_port_allocation", true)

  log_config {
    enable = true
    filter = lookup(var.nat_config, "log_filter", "ERRORS_ONLY")
  }
}
