locals {
  ip_group_ids = {
    for key, ip_group
    in azurerm_ip_group.this :
    replace(key, "\\", "/") => ip_group.id
  }
}