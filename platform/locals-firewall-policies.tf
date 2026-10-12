locals {
  firewall_policies_config = yamldecode(
    file(var.firewall_policies_configuration_file)
  )

  firewall_policies = try(
    local.firewall_policies_config.firewall_policies,
    {}
  )
}