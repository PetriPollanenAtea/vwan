locals {
  firewalls_config = yamldecode(
    file(var.firewalls_configuration_file)
  )
  firewalls = try(
    local.firewalls_config.firewalls,
    {}
  )
}
