project_id   = "fresh-84"
project_name = "fresh-84"
environment  = "dev"

vpc_cidr = "10.0.0.0/16"
regions  = ["us-central1", "us-east1", "europe-west1"]

auto_generate_subnets = true
tiers = [
  { name = "web",   purpose = "WEB_SERVERS",  private_ip_google_access = true,  flow_logs = true },
  { name = "api",   purpose = "API_SERVERS",   private_ip_google_access = false, flow_logs = true },
  { name = "cache", purpose = "REDIS_CLUSTER", private_ip_google_access = true,  flow_logs = true },
  { name = "db",    purpose = "CLOUD_SQL",     private_ip_google_access = true,  flow_logs = true },
  { name = "mgmt",  purpose = "BASTION",       private_ip_google_access = false, flow_logs = true },
]

web_access_cidrs = ["203.0.113.0/24", "198.51.100.0/24"]
admin_cidrs      = ["203.0.113.10/32"]
app_ports        = ["8080", "9090"]
db_ports         = ["5432", "6379"]

custom_firewall_rules = {
  "allow-monitoring" = {
    description = "Allow Prometheus/Grafana scraping"
    direction   = "INGRESS"
    priority    = 1000
    ranges      = ["10.0.5.0/24"]
    allow       = [{ protocol = "tcp", ports = ["9090", "3000", "10250", "443"] }]
    target_tags = ["monitored"]
  }

  # === CRITICAL for private GKE cluster node registration ===
  "gke-nodes-to-master" = {
    description = "Allow GKE nodes to reach private control plane (required for registration)"
    direction   = "EGRESS"
    priority    = 900          # Must be much higher priority than deny-all
    ranges      = ["172.16.0.0/28"]
    allow       = [{ protocol = "tcp", ports = ["443"] }]
    target_tags = ["gke-${var.cluster_name}*"]   # GKE auto-tags nodes; wildcard often works
  }

  "gke-nodes-to-google-apis" = {
    description = "Allow GKE nodes egress to Google APIs (image pulls, metadata, bootstrap)"
    direction   = "EGRESS"
    priority    = 910
    ranges      = ["199.36.153.4/30"]   # restricted.googleapis.com (best practice for private clusters)
    allow       = [{ protocol = "tcp", ports = ["80", "443"] }]
    target_tags = ["ai-ent"]
  }

  # Optional but recommended: Master → Nodes (GKE usually creates this, but explicit helps)
  "gke-master-to-nodes" = {
    description = "Allow control plane to reach nodes (kubelet, etc.)"
    direction   = "INGRESS"
    priority    = 920
    ranges      = []
    allow       = [{ protocol = "tcp", ports = ["443", "10250"] }]
    target_tags = ["ai-ent"]
  }
}

enable_nat  = true
nat_regions = ["us-central1", "us-east1"]
nat_subnet_mapping = {
  "us-central1" = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  "us-east1"    = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

nat_config = {
  min_ports_per_vm = 128
  log_filter       = "ALL"
}