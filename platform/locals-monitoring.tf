locals {
  monitoring_config = yamldecode(
    file(var.monitoring_configuration_file)
  )
  monitoring = local.monitoring_config.monitoring
}