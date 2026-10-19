variable "subscription_id" {
  description = "Azure subscription used for the deployment."
  type        = string
  sensitive   = true
}

variable "virtual_networks_configuration_file" {
  description = "Path to the Virtual Network YAML file."
  type        = string
  default     = "./config/virtual-networks.yml"
}

variable "virtual_wan_configuration_file" {
  description = "Path to the Virtual WAN YAML file."
  type        = string
  default     = "./config/virtual-wan.yml"
}

variable "virtual_hub_connections_configuration_file" {
  description = "Path to the Virtual Hub connections YAML file."
  type        = string
  default     = "./config/virtual-hub-connections.yml"
}

variable "existing_virtual_networks_configuration_file" {
  description = "Path to the YAML file containing existing Virtual Network resource IDs."
  type        = string
  default     = "./config/existing-virtual-networks.yml"
}

variable "vpn_sites_configuration_file" {
  type    = string
  default = "./config/vpn-sites.yml"
}

variable "vpn_connections_configuration_file" {
  description = "Path to the VPN Gateway Connection YAML configuration."
  type        = string
  default     = "./config/vpn-connections.yml"
}

variable "firewall_policies_configuration_file" {
  type    = string
  default = "./config/firewall-policies.yml"
}

variable "ip_groups_configuration_file" {
  type    = string
  default = "./config/ip-groups.yml"
}

variable "firewall_rule_collection_groups_path" {
  type    = string
  default = "./config/firewall-rule-collection-groups"
}

variable "firewalls_configuration_file" {
  type    = string
  default = "./config/firewalls.yml"
}

variable "monitoring_configuration_file" {
  type    = string
  default = "./config/monitoring.yml"
}

variable "vpn_psk_key_vault_id" {
  description = "Resource ID of the Azure Key Vault containing VPN pre-shared keys."
  type        = string
  default = "/subscriptions/5e8d8224-4e80-446e-95c1-eb71eb5c866f/resourceGroups/rg-keyvault/providers/Microsoft.KeyVault/vaults/kv-hpi-vwan-test"
}

variable "public_networks_via_onprem_configuration_file" {
  type    = string
  default = "./config/public-networks-via-onprem.yml"
}