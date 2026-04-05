variable "region" {
  type = string
}

variable "network_name" {
  type = string
}

variable "router_name" {
  type = string
}

variable "nat_name" {
  type = string
}

variable "subnet_name" {
  type    = string
  default = null
}

variable "min_ports_per_vm" {
  type    = number
  default = 64
}

variable "max_ports_per_vm" {
  type    = number
  default = 1024
}

variable "enable_dynamic_port_allocation" {
  type    = bool
  default = true
}

variable "log_filter" {
  type    = string
  default = "ERRORS_ONLY"
}

variable "bgp_asn" {
  type    = number
  default = 64514
}

variable "nat_subnet_mapping" {
  type        = map(string)
  description = "Map of region to NAT source IP range option (e.g. ALL_SUBNETWORKS_ALL_IP_RANGES or LIST_OF_SUBNETWORKS)"
  default     = {
    "us-central1" = "ALL_SUBNETWORKS_ALL_IP_RANGES"
    "us-east1"    = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  }
}

variable "nat_config" {
  type = object({
    min_ports_per_vm = optional(number, 128)
    log_filter       = optional(string, "ERRORS_ONLY")
  })
  description = "Configuration for Cloud NAT (min ports per VM and log filter)"
  default = {
    min_ports_per_vm = 128
    log_filter       = "ERRORS_ONLY"
  }
}

variable "subnets" {
  type = map(object({
    name                     = string
    region                   = string
    purpose                  = string
    ip_cidr_range           = string
    private_ip_google_access = optional(bool, false)
    flow_logs                = optional(bool, true)
    secondary_ip_ranges      = optional(map(object({
      range_name    = string
      ip_cidr_range = string
    })), {})
  }))
}