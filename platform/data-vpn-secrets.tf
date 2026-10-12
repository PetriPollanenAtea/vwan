data "azurerm_key_vault_secret" "vpn_psk" {
  for_each = local.vpn_psk_secret_references

  name         = each.value.secret_name
  key_vault_id = var.vpn_psk_key_vault_id
}