locals {
  ip_groups_config = yamldecode(
    file(var.ip_groups_configuration_file)
  )
  ip_groups = try(
    local.ip_groups_config.ip_groups,
    {}
  )
}