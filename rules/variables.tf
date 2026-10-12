variable "subscription_id" {
  description = "Azure subscription used for the deployment."
  type        = string
  sensitive   = true
}

variable "ip_groups_configuration_file" {
  type    = string
  default = "./config/ip-groups.yml"
}

variable "firewall_rule_collection_groups_path" {
  type    = string
  default = "./config/firewall-rule-collection-groups"
}

variable "firewall_policy_ids" {
  type    = list(string)
  default = []
}